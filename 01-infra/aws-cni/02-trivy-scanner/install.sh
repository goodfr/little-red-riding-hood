#!/usr/bin/env bash

helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update

kubectl create ns trivy-system
helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set="hostNetwork=true" \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.6.0

sleep 30

kubectl get vulnerabilityreports --all-namespaces -o wide

kubectl get configauditreports --all-namespaces -o wide