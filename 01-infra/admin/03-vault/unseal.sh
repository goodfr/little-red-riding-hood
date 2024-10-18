#!/usr/bin/env bash

export VAULT_ADDR="http://vault.aws.sphinxgaia.jeromemasson.fr"

vault operator unseal $(grep 'Key 1:' key-vault.txt | awk '{print $NF}')

sleep 2

vault login $(grep 'Initial Root Token:' key-vault.txt | awk '{print $NF}')