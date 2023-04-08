![Trivy Scanner](../../images/trivy_logo.png)

## Installation
Pour faciliter l'installation de trivy scanner, nous utiliserons l'image
docker de tooling que nous vous avons fourni.

```bash
export REPO_ROOT_DIR=<chemin vers le clone du projet>
docker run --rm -v $KUBECONFIG:/apps/kubeconfig.yaml -v $REPO_ROOT_DIR/02-demo/00-preconfig/01-kyverno:/apps/kyverno -it zebeurton/lab-devoxx/tooling bash
```

Une fois dans le container, vous pouvez positionner la variable KUBECONFIG
```bash
export KUBECONFIG=/app/kubeconfig.yaml
```

Nous utilisons la charte helm officielle pour installer et configurer kyverno dans notre cluster.

```bash
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
```

Une fois le repo connu de helm, nous pouvons installer la charte avec nos valeurs customisées

```bash
kubectl create ns trivy-system
helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.6.0
```

La charte helm installe l'operateur trivy qui permet de récupérer les 
audits et les vulnérabilités sur les images des containeurs déjà déployés
sur le cluster.

## Analyse du scan de Trivy

Vérifier les vulnérabilités détectées sur le namespace red et green:

```bash
kubectl get vulnerabilityreports -n red -o wide
kubectl get vulnerabilityreports -n green -o wide
```
Vérifier sur d'autres namespaces si des containers déployés ont des valeurs de CVE élevés.
Que pouvez-vous faire en cas de containers avec des CVE Critiques ?

Vérifier ensuite le rapport d'audit sur la configuration des déploiements
sur le namespace red puis green

```bash
kubectl get configauditreports -n red -o wide
kubectl get configauditreports -n green -o wide
```

Vérifier sur d'autres namespaces si des containers déployés ont des valeurs de CVE élevés.
Comment comprendre le scan d'audit de configuration ?