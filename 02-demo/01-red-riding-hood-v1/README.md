# Install Red Riding Hood

kubectl delete -f ../00-preconfig/01-kyverno/red-riding-hood-red-restricted.yaml

kubectl create ns red 
kubectl apply -n red -f manifest-red.yaml

kubectl create ns green 
kubectl apply -n green -f manifest-ma.yaml


kubectl apply -f ./00-preconfig/01-kyverno/red-riding-hood-red-restricted.yaml