#!/usr/bin/env bash

export KUBECONFIG="$1"

helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update

kubectl create ns trivy-system
helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.6.0

sleep 30

kubectl get vulnerabilityreports --all-namespaces -o wide