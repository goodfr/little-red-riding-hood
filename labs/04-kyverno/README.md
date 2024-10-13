# Exercice 04 : Sécurisation et Conformité avec Kyverno
![Kyverno](../../images/kyverno_logo.png)

Dans un village technologique où le Petit Chaperon Rouge voyageait, chaque application était comme un habitant ayant sa 
propre histoire et ses propres responsabilités. Cependant, un jour, un loup rusé s'est glissé dans le village, menaçant 
la sécurité des communications et l'intégrité de ces applications. La tranquillité du village était en jeu, et le Petit 
Chaperon Rouge savait qu'elle devait agir rapidement pour préserver l'harmonie de son royaume.

## But de l'Exercice

Dans cet exercice, nous allons explorer l'utilisation de **Kyverno**, un moteur de politiques pour Kubernetes, afin de 
garantir la sécurité et la conformité des applications déployées sur notre cluster. Nous déploierons des ressources 
à l'aide de Kyverno pour appliquer des politiques de contrôle qui aboutissent à un environnement plus sécurisé.

L'objectif est d'apprendre à définir et à appliquer des politiques qui contrôlent ce qui peut être déployé sur notre 
cluster, en interdisant les configurations non sécurisées ou non conformes. Vous découvrirez ainsi comment Kyverno 
peut contribuer à renforcer la sécurité de votre cluster Kubernetes.

## Pourquoi Utiliser Kyverno ?

Kyverno est un outil nécessaire pour la gestion des politiques dans Kubernetes car il permet aux équipes de sécurité ou 
d'administration de définir des exigences de sécurité et de conformité directement dans le cluster. 

Voici quelques avantages de son utilisation :

- **Déclaration de Politiques** : Avec Kyverno, vous pouvez définir des politiques de manière déclarative, ce qui 
facilite la gestion et la compréhension des règles applicables à votre environnement.
- **Application Automatique** : Les politiques peuvent être appliquées automatiquement aux ressources du cluster, 
garantissant que seules les configurations conformes sont acceptées.
- **Contrôle d'Accès** : Kyverno permet d'interdire certaines configurations ou d'exiger des attributs spécifiques pour 
- les déploiements, ce qui augmente la robustesse de votre sécurité.
- **Rapports de Conformité** : Kyverno fournit des rapports sur la conformité des déploiements, permettant de suivre 
- l'adhésion aux politiques et d'identifier les violations.

## Installation de Kyverno

Pour commencer, nous allons installer Kyverno dans notre cluster Kubernetes. Suivez les étapes ci-dessous :

```bash
export REPO_ROOT_DIR=$(pwd)
export KUBECONFIG=$(pwd)/kubeconfig
docker run --rm -v $KUBECONFIG:/home/tooling/.kube/config -v $REPO_ROOT_DIR/labs:/labs -it ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest
```

Déplacer vous dans le dossier du lab:

```bash
cd /labs/01-kyverno
```

Vérifier que vous avez bien accés à votre cluster Kubernetes :
```bash
kubectl get namespaces
```

Vous devriez obtenir une sortie similaire à celle-ci :
```
NAME              STATUS   AGE
default           Active   29h
kube-system       Active   29h
kube-public       Active   29h
kube-node-lease   Active   29h
red               Active   29h
```

Nous utilisons la charte helm officielle pour 
installer et configurer kyverno dans notre cluster.

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

Une fois le repo connu de helm, nous pouvons installer la charte avec nos valeurs customisées

```bash
kubectl create ns kyverno
helm upgrade --install kyverno kyverno/kyverno -n kyverno -f overrides.yaml --version 3.2.7
```
## Ajout de politiques sur le cluster

Créez un déploiement d'un Nginx en appliquant le manifeste présent dans le répertoire tests :

```bash
kubectl apply -f manifests/nginx-deployment.yaml
```

Vérifiez si le déploiement Nginx a été effectué dans le namespace par défaut. 
```bash
kubectl get deploy nginx -n default
```

> 💡 **Astuces** : 
> * Kyverno installe de nouveaux objets dans le cluster pour gérer les politiques. En particulier,
>  une ClusterPolicy est une politique globale qui peut être appliquée à tous les namespaces d'un cluster Kubernetes. 
>  Elle définit des règles de validation, d'admission ou d'audit concernant les ressources qui peuvent être créées ou 
> mises à jour dans le cluster.
> 

Pour savoir quelles sont les règles de validation déployées sur votre cluster, exécuter la commande suivante:
```bash
kubectl get clusterpolicy -A
```

Vous obtiendrez une liste de toutes les ClusterPolicy disponibles dans votre cluster. 
Cela vous aidera à savoir quelles politiques sont actuellement appliquées et actives, ainsi que leurs états 
(si elles ont été appliquées avec succès ou non).

Actuellement, aucune politique n'a encore été définies au niveau du cluster.
Vous devriez avoir la sortie suivante dans votre console:

```text
No resources found
```

Ce qui vous démontre qu'il n'y a pas de policy kyverno déployé sur le cluster

### Découvrons les politiques

Vérifiez la politique décrite dans le fichier manifests/red-riding-hood-red-clusterpolicy.yaml. 

> ⁉️ Qu'est-ce qu'elle autorise ?

Cette politique Kyverno requirements-red impose deux conditions :

1. Chaque déploiement créé dans le cluster doit avoir un label **bobinette** dont la valeur est **pull**.
2. Les conteneurs dans ces déploiements doivent utiliser une image spécifique dont la valeur du tag doit être **red**.

Si un utilisateur essaie de créer un déploiement qui ne respecte pas ces conditions, le déploiement sera bloqué et ne 
pourra pas être créé. Ce mécanisme aide à garantir que toutes les applications déployées suivent des règles de 
configuration prédéfinies, renforçant ainsi la conformité et la sécurité dans le cluster.

### Ajout d'une politique de sécurité

Appliquer la politique vu précédemment:

```bash
kubectl apply -f manifests/red-riding-hood-red-clusterpolicy.yaml
```

Vérifier que la politique est bien définie au niveau du cluster:
```bash
kubectl get clusterpolicy -A
```

Accéder au rapport de conformité
```bash
kubectl get policyreport -A
```

> 💡 **Astuces** :
> Pour avoir un résumé des conformités détectées, vous pouvez faire un describe sur le policyreport.


> ⁉️ 
> * Combien de déploiements sont actuellement en conformité ?
> * Notre déploiement de nginx est-il conforme ?

## Test du déploiement d'une nouvelle version de nginx

Déployer une nouvelle version de l'image nginx en utilisant la commande suivante:
```bash 
kubectl set image deployment/nginx nginx=nginx:latest
```

Vérifier si le déploiement a été effectué avec succès:

```bash
kubectl get policyreport -A
```
Vous devriez obtenir un échec de deployement du pods.

> 💡 **Astuces** :
> Pour voir les détails de l'échec, vous pouvez consulter les évènements associés au déploiement.
 
```bash
kubectl describe deployment nginx
```

## Test du déploiement d'une nouvelle version de notre application

Appliquer le fichier ../manifests/01-red-riding-hood-red-hood-v1/manifest-red.yaml qui est conforme à notre politique.

```bash
kubectl apply -f ../manifests/01-red-riding-hood-red-hood-v1/manifest-red.yaml
```

Vérifier que les évènements sont bien en succès.

```bash
kubectl get policyreport -A
```
## Suppression des ressources inutiles
```bash
kubectl delete -f manifests/nginx-deployment.yaml -n default
```

## Aide pour le debug 

Si vous avez besoin de déboguer votre configuration, vous pouvez exécuter les commandes suivantes pour vérifier l'état :

```bash
kubectl run busybox --rm -ti --image=busybox -- /bin/sh
wget --no-check-certificate --spider --timeout=1 https://kyverno-svc.kyverno.svc:443/health/liveness
```

## Conclusion

Vous avez appris à déployer Kyverno dans votre cluster Kubernetes et à appliquer des politiques de sécurité et de 
conformité. Grâce à Kyverno, vous avez non seulement renforcé la sécurité de votre environnement, mais vous avez 
également instauré un cadre qui garantit que seules les applications conformes peuvent être déployées.

> Tout comme le Petit Chaperon Rouge a su protéger son village en établissant des règles claires pour se défendre 
> contre le danger du loup, vous avez mis en place des politiques avec Kyverno qui protègent votre royaume numérique 
> des configurations non sécurisées et des menaces potentielles. Grâce à votre vigilance et à vos actions, le village 
> peut maintenant prospérer en toute tranquillité, loin des griffes du loup.

Suite de l'aventure : [05 - Sécurisation de l'API du Cluster avec HashiCorp Boundary](../05-boundary/README.md)