# Installation de Vault + son injecteur

## Edito

Et si mère grand déposée sont digicodes d'entrées dans un vault et que seul goldie rouge pouvait y accéder.

> Le but: 
> 
> Trouver les configurations qui empèchent le loup d'obtenir le secret

Le dossier du lab : `03-red-riding-hood-v1-vault`

## Installation

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm repo update

kubectl create namespace vault
```

## Configure override.yaml

```bash
helm upgrade --install vault hashicorp/vault -n vault -f override.yaml
```

## Unseal du Vault

```bash
kubectl exec -n vault vault-0 -it -- sh

cd

export VAULT_ADDR="http://127.0.0.1:8200"

vault operator init -key-shares=1 -key-threshold=1 > key-vault.txt

sleep 2

vault operator unseal $(grep 'Key 1:' key-vault.txt | awk '{print $NF}')

sleep 2

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')
```

## Create d'un dépôt de secret

```bash
kubectl exec -n vault vault-0 -it -- sh

cd

export VAULT_ADDR="http://127.0.0.1:8200"

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')

vault secrets enable -path=little-red kv-v2 

vault secrets list -detailed

```

## Configuration de votre cluster


Configuration d'un policy vault pour accéder au secret `grand-ma-secret`

```bash

cat <<EOF > little-red-policy.hcl
path "little-red/data/grand-ma-secret" {  capabilities = ["read"] }
EOF
# command to write policy
vault policy write little-red little-red-policy.hcl

```

Configuration de l'intégration de Kubernetes dans vault

```bash

vault auth enable kubernetes

vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault write auth/kubernetes/role/little-red \
bound_service_account_names=red-little-red-riding-hood-goldie-body \
bound_service_account_namespaces=red-zero-trust \
policies=little-red \
ttl=24h
```

## Configuration du secret

```bash
vault kv put little-red/grand-ma-secret bobinette=pull
```

## Déployer et Patchter l'application du patch de connexion avec Vault

```bash
kubectl apply -f static

kubectl patch deployment -n red-zero-trust little-red-riding-hood-goldie-body --patch "$(cat patch.yaml)"
```

Trouver les configurations qui empèchent le loup d'obtenir le secret

## Déployer et Patcher l'application dans le dossier success

```bash
kubectl apply -f success

kubectl patch deployment -n red-zero-trust little-red-riding-hood-goldie-body --patch "$(cat patch.yaml)"
```