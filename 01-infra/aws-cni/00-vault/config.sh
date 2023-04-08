#!/usr/bin/env bash

export VAULT_ADDR="http://vault.aws.sphinxgaia.jeromemasson.fr"

vault secrets enable -path=vclusters kv-v2 
