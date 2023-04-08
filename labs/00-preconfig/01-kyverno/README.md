![Kyverno](../../images/kyverno_logo.png)

## Installation

Pour faciliter l'installation de kyverno, nous utiliserons l'image
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
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

Une fois le repo connu de helm, nous pouvons installer la charte avec nos valeurs customisées

```bash
kubectl create ns kyverno

helm upgrade --install kyverno kyverno/kyverno -n kyverno  -f overrides.yaml --version v2.5.5
```
## Ajout de politique sur le cluster

Créer un déploiement d'un nginx en appliquant le manifeste présent dans le répertoire tests.

```bash
kubectl apply -f tests/test.yaml
```

Vérifier si le déploiement nginx a été effectué sur le ns par defaut.
Combien y a-t-il de pods déployé ?
Est-ce que kyverno a détecté la violation d'une ou plusieurs politiques ?

```bash
kubectl get policyreport -A
```

Vérifier la politique décrite dans le fichier red-riding-hood-red.yaml. Qu'est ce qu'elle autorise ?

Appliquer cette politique puis vérifier le status et le rapport

```bash
kubectl apply -f red-riding-hood-red.yaml
kubectl get clusterpolicy -A
kubectl get policyreport -A
```

Que constatez-vous ?

## Test du déploiement d'un nouveau composant

Appliquer de nouveau le déploiement nginx. Que constatez-vous ?

```bash
kubectl create ns test
kubectl apply -n test -f tests/test.yaml
kubectl delete ns test
```

## Aide pour le debug 

```bash
kubectl run busybox --rm -ti --image=busybox -- /bin/sh
wget --no-check-certificate --spider --timeout=1 https://kyverno-svc.kyverno.svc:443/health/liveness
```