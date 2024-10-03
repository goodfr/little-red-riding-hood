# Exercice : Analyse des Vulnérabilités avec Trivy

![Trivy Scanner](../../images/trivy_logo.png)

## But de l'Exercice

Dans cet exercice, nous allons utiliser **Trivy**, un scanner de vulnérabilités open-source, pour analyser les images 
de conteneurs déployées au sein de notre cluster Kubernetes. L'objectif est de détecter les vulnérabilités connues (CVE)
et d'évaluer la sécurité des applications en cours d'exécution.

## Pourquoi utiliser Trivy ?

**Trivy** est un outil essentiel pour toute équipe cherchant à renforcer la sécurité de ses applications conteneurisées.
Son utilisation dans les chaînes CI/CD permet d'identifier les vulnérabilités connues aussi bien dans le code source que
dans les images de conteneurs dès la phase de construction, avant même qu'elles ne soient déployées. 

Cela signifie que les développeurs peuvent corriger les problèmes de sécurité en amont, réduisant ainsi les risques 
associés à des déploiements de logiciels vulnérables. En intégrant Trivy dans le pipeline CI/CD, les équipes bénéficient
d'une visibilité immédiate sur les failles potentielles, ce qui favorise des pratiques de développement plus sécurisées. Dans le contexte d'exécution Kubernetes, Trivy se révèle tout aussi précieux, permettant une surveillance continue des images déjà déployées. Il analyse régulièrement les conteneurs en cours d'exécution et génère des rapports sur les vulnérabilités, ce qui aide les équipes à réagir rapidement aux nouvelles menaces. Ainsi, Trivy joue un rôle clé dans une stratégie de sécurité proactive, offrant une couverture tant lors des phases de développement que d'exécution au sein de l'environnement Kubernetes.

Le cycle de vie de nos applications ne s'arrête pas à la phase de développement et de construction. Il est donc 
essentiel de surveiller les vulnérabilités des images de conteneurs en production, afin de garantir un niveau de 
sécurité plus élevé. Ainsi, il est recommandé d'intégrer Trivy aussi bien dans votre pipeline CI/CD et de l'utiliser 
pour détecter de nouvelles failles de sécurité une fois l'application en production.

## Installation de Trivy

Pour commencer, nous allons installer Trivy dans notre cluster Kubernetes. Suivez les étapes ci-dessous :

```bash
export REPO_ROOT_DIR=$(pwd)
export KUBECONFIG=$(pwd)/kubeconfig
docker run --rm -v $KUBECONFIG:/home/tooling/.kube/config -v $REPO_ROOT_DIR/labs:/labs -it ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest
```

Déplacez-vous dans le dossier du lab :
```bash
cd /labs/02-trivy-scanner
```

Vérifiez que vous avez bien accès à votre cluster Kubernetes :
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
kyverno           Active   29h
red               Active   29h
```

Nous allons maintenant ajouter le Helm repository de Aqua Security pour installer l'opérateur Trivy :

```bash
helm repo add aquasec https://aquasecurity.github.io/helm-charts
helm repo update
```

Une fois le repo connu de helm, nous pouvons installer la charte avec nos valeurs customisées

```bash
kubectl create ns trivy-system
helm upgrade --install trivy-operator aqua/trivy-operator \
    --namespace trivy-system \
    --set="trivy.ignoreUnfixed=true" \
     --version 0.24.0
```

L'installation de la charte Helm met en place l'opérateur Trivy, qui permet de récupérer les rapports d'audit et de 
vulnérabilités sur les images des conteneurs déjà déployées dans le cluster.

## Analyse des vulnérabilités détectées par Trivy

### Déploiement d'une Image Docker avec CVE Sévère
Nous allons déployer une application contenant une vulnérabilité connue. Pour ce faire, nous utiliserons ici l'image 
node:14-alpine qui contient une vulnérabilité **CVE-2021-23337**.

Appliquer le manifeste suivant sur votre cluster:

```bash
kubectl apply -f manifests/cve-deployment.yaml
```

Vérifiez que le déploiement a réussi et que le pod fonctionne :

```bash
kubectl get pods
```

> 💡 **Astuces** : 
> Trivy installe de nouveaux objets dans le cluster pour obtenir les résultats d'analyse de vulnérabilité. 
> En particulier, L'objet VulnerabilityReports qui centralise les différents niveaux de vulnérabilité détectés
> sur le namespace
> 
Vérifier les rapports de vulnérabilités:
```bash
kubectl get vulnerabilityreports -n default -o wide
```

Après l'analyse, vous pouvez supprimer le déploiement que vous venez de créer :

```bash
kubectl delete -f cve-deployment.yaml
```

### Détection des vulnérabilités sur notre application
Pour vérifier les vulnérabilités détectées dans le namespace red, vous pouvez utiliser la commande suivante :

```bash
kubectl get vulnerabilityreports -n red -o wide
```

Que pouvez-vous faire en cas de conteneurs présentant des CVE critiques ?

Ensuite, vérifiez le rapport d'audit sur la configuration des déploiements dans le namespace red :

```bash
kubectl get configauditreports -n red -o wide
```

