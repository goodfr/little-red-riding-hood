


helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm repo update

kubectl create namespace vault

helm upgrade --install vault hashicorp/vault -n vault -f override.yaml

export VAULT_ADDR=http://vault.aws.sphinxgaia.jeromemasson.fr

vault operator init -key-shares=1 -key-threshold=1 > key.txt

sleep 2

vault operator unseal $(grep 'Key 1:' key.txt | awk '{print $NF}')

sleep 2

vault login $(grep 'Initial Root Token:' key.txt | awk '{print $NF}')


vault secrets enable -path=test4 kv-v2 
vault kv put test4/test titi=tata
vault kv get test4/test 

vault auth enable kubernetes


In container

VAULT_TOKEN=$(cat ~/.vault-root_token) VAULT_ADDR=http://127.0.0.1:8200 vault write auth/kubernetes/config \
   kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443

cat tests/policy.hcl | vault policy write testpol -


vault write auth/kubernetes/role/demo \
    bound_service_account_names=test \
    bound_service_account_namespaces=red \
    policies=testpol \
    ttl=12h

vault policy read testpol
vault read auth/kubernetes/role/demo

## Init Vault

## Test Vault

export VAULT_TOKEN=$(cat ~/.vault-root_token)
export VAULT_ADDR=http://a01913637ccca40029ac76ab626f8f7d-980977184.eu-west-1.elb.amazonaws.com:8200

vault secrets enable -path=test2 kv-v2 
vault kv put test2/test titi=tata
vault kv get test2/test 

kubectl apply -f tests/test.yaml

## Add TLS Termination

> Missing some SANs
./gen-cert.sh 

hvs.ZZDsiONWZouNjiz0JDosoBmY