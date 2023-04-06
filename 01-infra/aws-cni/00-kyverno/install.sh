#!/usr/bin/env bash

helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

kubectl create ns kyverno

helm upgrade --install kyverno kyverno/kyverno -n kyverno  -f overrides.yaml --version v2.5.5

kubectl apply -f red-riding-hood-red.yaml
kubectl get clusterpolicy -A
