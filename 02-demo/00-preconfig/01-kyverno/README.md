## Install Kyverno

helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

aws-vault exec custom -- kubectl create ns kyverno

aws-vault exec custom -- helm upgrade --install kyverno kyverno/kyverno -n kyverno  -f overrides.yaml --version v2.5.5

aws-vault exec custom -- k9s
aws-vault exec custom -- kubectl apply -f test.yaml

aws-vault exec custom -- kubectl apply -f red-riding-hood-red.yaml
aws-vault exec custom -- kubectl get clusterpolicy -A

## Test Kyverno install

aws-vault exec custom -- kubectl create ns test
aws-vault exec custom -- kubectl apply -n test -f test.yaml
aws-vault exec custom -- kubectl delete ns test

## Debug Install

aws-vault exec custom -- kubectl run busybox --rm -ti --image=busybox -- /bin/sh

wget --no-check-certificate --spider --timeout=1 https://kyverno-svc.kyverno.svc:443/health/liveness

> Be sure your EKS Kubernetes-APIServer Security Group can access node-security-group ports