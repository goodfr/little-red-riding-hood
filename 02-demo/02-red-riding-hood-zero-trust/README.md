
# RED

export HELMPATH=/mnt/c/Users/styli/Documents/k8s/sphinxgaia/git/goldies/deploy/_goldies/helm/red-riding-hood/


## BAD

kubectl create ns red-zero-trust
kubectl apply -n red-zero-trust -f manifest-red.yaml

kubectl create ns green-zero-trust
kubectl apply -n green-zero-trust -f manifest-ma.yaml


## GOOD

boundary connect kube -target-id ttcp_XsZGeUadVz -- create ns green-zero-trust
boundary connect kube -target-id ttcp_XsZGeUadVz -- apply -n green-zero-trust -f manifest-ma.yaml

boundary connect kube -target-id ttcp_XsZGeUadVz -- create ns red-zero-trust
boundary connect kube -target-id ttcp_XsZGeUadVz -- apply -n red-zero-trust -f manifest-red.yaml