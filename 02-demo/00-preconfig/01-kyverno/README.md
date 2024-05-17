## Install Kyverno

helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

helm search repo kyverno -l

kubectl create ns kyverno

helm upgrade --install kyverno kyverno/kyverno -n kyverno  -f overrides.yaml --version 3.2.2

kubectl apply -f tests/test.yaml

kubectl get po -n default

kubectl delete -f tests/test.yaml

kubectl apply -f red-riding-hood-red.yaml
kubectl get clusterpolicy -A

kubectl apply -f tests/test.yaml

Enforce restriction

kubectl apply -f red-riding-hood-red-restricted.yaml
kubectl get clusterpolicy

kubectl get clusterpolicy requirements-red | less


## Test Kyverno install

kubectl create ns test
kubectl apply -n test -f test.yaml
kubectl delete ns test

## Debug Install

kubectl run busybox --rm -ti --image=busybox -- /bin/sh

wget --no-check-certificate --spider --timeout=1 https://kyverno-svc.kyverno.svc:443/health/liveness

> Be sure your EKS Kubernetes-APIServer Security Group can access node-security-group ports