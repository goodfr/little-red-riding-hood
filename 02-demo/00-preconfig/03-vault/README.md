# Vault Install


helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update


helm search repo hashicorp/vault

helm search repo vault -l

kubectl create namespace vault

helm upgrade --install vault hashicorp/vault -n vault -f override.yaml


## Init Vault

export VAULT_ADDR='http://vault.kind.cluster' 
vault operator init -key-shares=1 -key-threshold=1 > unseal-key.txt
vault operator unseal $(grep 'Key 1:' unseal-key.txt | awk '{print $NF}')


## Test Vault

export VAULT_TOKEN=$(grep 'Initial Root Token:' unseal-key.txt | awk '{print $NF}')

vault auth enable kubernetes

cat tests/policy.hcl | vault policy write testpol -

export INCLUSTER_KUBERNETES_API=$(kubectl get svc kubernetes -o jsonpath={.spec.clusterIP})

vault write auth/kubernetes/config \
   kubernetes_host=https://${INCLUSTER_KUBERNETES_API}:443

vault write auth/kubernetes/role/demo \
    bound_service_account_names=test \
    bound_service_account_namespaces=red \
    policies=testpol \
    ttl=12h

vault policy read testpol
vault read auth/kubernetes/role/demo

vault secrets enable -path=kv kv-v2 
vault kv put kv/test titi=tata
vault kv get kv/test 

kubectl apply -f tests/test.yaml


## Add TLS Termination

> Missing some SANs
./gen-cert.sh 


## Debug Install

kubectl run busybox --rm -ti --image=busybox -- /bin/sh
