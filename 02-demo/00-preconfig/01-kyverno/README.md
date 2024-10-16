# Install Kyverno

## Install with HELM 

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

helm search repo kyverno -l
```

Create Kyverno NS

```bash
kubectl create ns kyverno
```

```bash
helm upgrade --install kyverno kyverno/kyverno -n kyverno  -f overrides.yaml --version 3.2.2
```

Test installation

```bash
kubectl apply -f tests/test.yaml
```

Check result

```bash
kubectl get po -n default
```

Clean

```bash
kubectl delete -f tests/test.yaml
```

Apply `cluster policy`

```bash
kubectl apply -f red-riding-hood-red.yaml
kubectl get clusterpolicy -A
```

Test again

```bash
kubectl apply -f tests/test.yaml
```

Enforce restriction

```bash
kubectl apply -f red-riding-hood-red-restricted.yaml
kubectl get clusterpolicy
```

```bash
kubectl get clusterpolicy requirements-red | less
```

## Test Kyverno install

```bash
kubectl create ns test
kubectl apply -n test -f test.yaml
kubectl delete ns test
```

## Debug Install

```bash
kubectl run busybox --rm -ti --image=busybox -- /bin/sh

wget --no-check-certificate --spider --timeout=1 https://kyverno-svc.kyverno.svc:443/health/liveness
```

> Be sure your EKS Kubernetes-APIServer Security Group can access node-security-group ports

