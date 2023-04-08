# Installation de Vault + son injecteur

## Installation

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm repo update

kubectl create namespace vault

## Configure override.yaml

helm upgrade --install vault hashicorp/vault -n vault -f override.yaml

## Unseal du Vault

kubectl exec -n vault vault-0 -it -- sh

cd

export VAULT_ADDR="http://127.0.0.1:8200"

vault operator init -key-shares=1 -key-threshold=1 > key-vault.txt

sleep 2

vault operator unseal $(grep 'Key 1:' key-vault.txt | awk '{print $NF}')

sleep 2

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')

## Create d'un dépôt de secret

kubectl exec -n vault vault-0 -it -- sh

cd

export VAULT_ADDR="http://127.0.0.1:8200"

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')

vault secrets enable -path=vclusters kv-v2 
