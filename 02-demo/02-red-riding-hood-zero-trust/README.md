
# RED

export HELMPATH=/mnt/c/Users/styli/Documents/k8s/sphinxgaia/git/goldies/deploy/_goldies/helm/red-riding-hood/


## BAD

aws-vault exec custom -- kubectl create ns red-zero-trust 
aws-vault exec custom -- helm upgrade --install red --namespace red-zero-trust -f overrides.yaml $HELMPATH

aws-vault exec custom -- kubectl get svc -n red-zero-trust

aws-vault exec custom -- kubectl create ns green-zero-trust 
aws-vault exec custom -- helm upgrade --install green --namespace green-zero-trust -f overrides-fake.yaml $HELMPATH


aws-vault exec custom -- kubectl get svc -n green-zero-trust

## GOOD

aws-vault exec custom -- boundary connect kube -target-id ttcp_XsZGeUadVz -- create ns green-zero-trust
aws-vault exec custom -- boundary connect kube -target-id ttcp_XsZGeUadVz -- apply -n green-zero-trust -f manifest-ma.yaml

aws-vault exec custom -- boundary connect kube -target-id ttcp_XsZGeUadVz -- create ns red-zero-trust
aws-vault exec custom -- boundary connect kube -target-id ttcp_XsZGeUadVz -- apply -n red-zero-trust -f manifest-red.yaml