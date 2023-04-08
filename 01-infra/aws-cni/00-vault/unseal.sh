#!/usr/bin/env bash

export VAULT_ADDR="http://vault.aws.sphinxgaia.jeromemasson.fr"

vault operator init -key-shares=1 -key-threshold=1 > key-vault.txt

sleep 2

vault operator unseal $(grep 'Key 1:' key-vault.txt | awk '{print $NF}')

sleep 2

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')