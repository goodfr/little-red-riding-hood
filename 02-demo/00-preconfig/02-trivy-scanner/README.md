# Install trivy scanner

## Install with HELM 

```bash
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
```

check available version

```bash
helm search repo trivy-operator -l
```

Install trivy

```bash
kubectl create ns trivy-system
helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.22.1
```

## Test 

```bash
kubectl apply -f tests/test.yaml
```

Check what happened

```bash
kubectl get po -n trivy-system -w 
```

Retreive info from operator


```bash
kubectl get vuln -n red

kubectl get configaudit -n red

kubectl get rbacassessmentreports -n red
```