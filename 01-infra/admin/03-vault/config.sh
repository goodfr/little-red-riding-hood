#!/usr/bin/env bash

export VAULT_ADDR="http://vault.aws.sphinxgaia.jeromemasson.fr"
export VAULT_SKIP_VERIFY=TRUE

vault operator init -key-shares=1 -key-threshold=1 > key.txt

sleep 2

vault operator unseal $(grep 'Key 1:' key-vault.txt | awk '{print $NF}')

sleep 2

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')

vault auth enable userpass

vault secrets enable -path=vclusters kv-v2 
