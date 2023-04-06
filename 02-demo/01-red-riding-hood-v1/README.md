
# RED

export HELMPATH=/mnt/c/Users/styli/Documents/k8s/sphinxgaia/git/goldies/deploy/_goldies/helm/red-riding-hood/

kubectl create ns red 
helm upgrade --install red --namespace red -f overrides-red.yaml $HELMPATH

kubectl get svc -n red

kubectl create ns green 
helm upgrade --install green --namespace green -f overrides-ma.yaml $HELMPATH


kubectl get svc -n green