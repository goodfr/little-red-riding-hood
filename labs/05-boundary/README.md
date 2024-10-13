# Sécurisation de l'API du Cluster avec HashiCorp Boundary

![Boundary](../../images/boundary_logo.png)

Dans un village paisible, Mère Grand protégeait jalousement ses secrets, dissimulant ses codes d’entrée dans un 
coffre-fort. Pour assurer sa sécurité, elle savait qu'elle devait éviter que le maléfique loup, toujours en quête 
d'aventures malicieuses, ne mette la main sur ses précieuses informations. Avec l'aide de l'innocente Goldie Rouge, 
la seule autorisée à pénétrer dans le sanctuaire de Mère Grand, ils décidèrent de renforcer la protection de ces 
secrets vitaux grâce à une technologie moderne.

## But de l'Exercice

L'objectif de cet exercice est de déployer HashiCorp Boundary sur votre cluster Kubernetes afin de sécuriser l'accès à 
l'API. Boundary offre un moyen efficace de gérer et de contrôler l'accès aux ressources des applications, tout en 
permettant une traçabilité des connexions. À travers cet exercice, vous apprendrez à configurer Boundary pour protéger 
l'API et à établir des connexions sécurisées vers vos services déployés.


## Pourquoi utiliser Boundary

HashiCorp Boundary est un outil essentiel pour sécuriser les environnements cloud et Kubernetes. Il facilite la gestion 
des accès aux services sensibles en remplaçant les mécanismes traditionnels de sécurité par un modèle d’accès dynamique 
basé sur des identités. En utilisant Boundary, vous pouvez limiter les risques d'accès non autorisé à vos ressources, 
et garantir une meilleure traçabilité des actions des utilisateurs. Sa capacité à s'intégrer avec des systèmes 
d'authentification modernes et à fournir des sessions d'accès temporaires en fait un choix idéal pour protéger l'API 
de votre cluster et vos services.

## Installation de Boundary

Pour installer Boundary sur votre cluster, vous allez utiliser Terraform pour déployer les ressources nécessaires. 
Suivez les étapes ci-dessous :

1. **Initialiser le projet Terraform :** Exécutez la commande suivante pour initialiser Terraform :

```bash
terraform init
```

2. **Créer le Namespace Boundary :**
Exécutez les commandes suivantes pour créer le namespace et appliquer les configurations Terraform :


```bash
kubectl create ns boundary
terraform apply -target module.kubernetes -auto-approve
```

3. **Exportez l'adresse de Boundary :**
```bash
export BOUNDARY_ADDR="http://ac6c7a66b9daf4986939b7e7dae09ff0-1723290738.eu-west-1.elb.amazonaws.com:9200" 
terraform apply -auto-approve
```

4. **Exposer les Services Boundary :**
Utilisez kubectl port-forward pour exposer les services Boundary sur votre machine locale. Cela nécessite d'exécuter trois commandes dans trois terminaux séparés :

```bash
kubectl port-forward pods/$(kubectl get pods | grep boundary | cut -d " " -f 1) 9200:9200
kubectl port-forward pods/$(kubectl get pods | grep boundary | cut -d " " -f 1) 9201:9201
kubectl port-forward pods/$(kubectl get pods | grep boundary | cut -d " " -f 1) 9202:9202
```

5. **Configurer Boundary :**
Appliquez les configurations nécessaires pour Boundary en utilisant l'adresse externe que vous avez exposée :

```bash
# Set the external address for your service
export KUBE_SERVICE_ADDRESS=$(echo "http://127.0.0.1:9200")
terraform apply -target module.boundary -var boundary_addr=$KUBE_SERVICE_ADDRESS
```

6. **Verifier les déploiements :**
```bash
kubectl get deployments
```

## Se connecter à Boundary

Exporter la variable d'environnement `BOUNDARY_ADDR` avec l'adresse de votre service Boundary :

```bash
export BOUNDARY_ADDR=http://localhost:9200
```

Récupérer le token d'accès à Boundary en utilisant l'outil jq qui permet de manipuler les données JSON :

```bash
boundary scopes list -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]"
boundary auth-methods list -scope-id $(boundary scopes list -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"')
boundary auth-methods list -scope-id  -format json $(boundary scopes list -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"')

# set BOUNDARY_AUTH_METHOD_ID

export BOUNDARY_SCOPE=$(boundary scopes list -keyring-type=none -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]")
export BOUNDARY_AUTH_METHOD_ID=$(boundary auth-methods list -keyring-type=none -format json -scope-id $(boundary scopes list -keyring-type=none -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"') | jq -c ".items[] | .id" |  sed -e 's/^"//' | sed -e 's/"$//' )
```

Vous devriez voir une sortie similaire à celle-ci :

```
Auth Method information:
  ID:             ampw_1234567890
    Description:  Provides initial administrative authentication into Boundary
    Name:         Generated global scope initial auth method
    Type:         password
    Version:      1
```

Vous pouvez maintenant vous connecter à Boundary en utilisant le nom d'utilisateur et le mot de passe par défaut :

```bash
boundary authenticate password \
  -login-name=mark \
  -password=foofoofoo \
  -auth-method-id=${BOUNDARY_AUTH_METHOD_ID}
```

Depuis l'interface utilisateur ou la CLI, vous pouvez maintenant accéder à Boundary et voir les ressources disponibles.
Récupérer le target ID pour le container Redis dans le projet databases. Si vous utilisez la CLI, vous voudrez lister
les scopes du scope `primary` que nous avons créé avec Terraform :  

```bash
$ boundary scopes list
<get scope ID for primary org>
$ boundary scopes list -scope-id <primary org ID>
```

Maintenant que vous avez le scope ID du projet databases, vous pouvez lister les targets (encore une fois, en utilisant
quelques commandes JQ pour obtenir le bon scope ID pour le scope `primary`).

```bash
boundary targets list -scope-id <project_scope_id>
```

> **Note:** Vous pouvez également accéder à la console d'administration, vous connecter, aller dans les projets, puis 
> les cibles et le copier depuis l'interface utilisateur.
You can also navigate to the admin console, login, go to projects, and then targets and copy it from the UI.


## Créer un accès à Boundary
Vous pouvez maintenant créer un accès à Boundary pour vous connecter à un service. Pour cela, vous devez créer un accès
à Boundary en utilisant le scope ID du projet databases et le target ID du container Redis. Vous pouvez également
spécifier une durée d'accès pour cet accès. Par exemple, pour créer un accès à Boundary pour le container Redis où 
notre target ID est `ttcp_TBjC1bYRIQ` :

```bash
boundary connect -exec redis-cli -target-id ttcp_TBjC1bYRIQ -- -h {{boundary.ip}} -p {{boundary.port}}
```

Vous pouvez maintenant vous connecter à Redis en utilisant Boundary. Vous pouvez également utiliser Boundary pour
établir des connexions sécurisées vers d'autres services déployés sur votre cluster Kubernetes.

Exemple de connexion à Redis :

```bash
127.0.0.1:57159> ping
PONG
127.0.0.1:57159>
```

## Conclusion

Vous avez maintenant déployé HashiCorp Boundary sur votre cluster Kubernetes, sécurisant ainsi l'accès à l'API de votre 
cluster. En utilisant Boundary, vous pouvez gérer de manière dynamique l'accès aux ressources, limitant les possibilités
d'intrusion et améliorant la sécurité globale de l'environnement. Cette configuration vous permettra de fournir un accès
contrôlé et auditée à vos services tout en préservant la convivialité nécessaire pour les utilisateurs et les 
développeurs. Profitez de la tranquillité d'esprit que procure une architecture sécurisée grâce à Boundary.