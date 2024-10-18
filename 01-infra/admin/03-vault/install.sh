#!/usr/bin/env bash

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm repo update

kubectl create namespace vault

helm upgrade --install vault hashicorp/vault -n vault -f override.yaml
