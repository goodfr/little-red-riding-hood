
# RED

export HELMPATH=/mnt/c/Users/styli/Documents/k8s/sphinxgaia/git/goldies/deploy/_goldies/helm/red-riding-hood/

aws-vault exec custom -- kubectl create ns red 
aws-vault exec custom -- helm upgrade --install red --namespace red -f overrides-red.yaml $HELMPATH

aws-vault exec custom -- kubectl get svc -n red

aws-vault exec custom -- kubectl create ns green 
aws-vault exec custom -- helm upgrade --install green --namespace green -f overrides-ma.yaml $HELMPATH


aws-vault exec custom -- kubectl get svc -n green