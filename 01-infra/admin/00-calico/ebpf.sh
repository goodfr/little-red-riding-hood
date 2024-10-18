#!/usr/bin/env bash

cat <<EOF | kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "$(kubectl config view --minify -o jsonpath='{.clusters[].cluster.server}' | sed 's#https://##' )"
  KUBERNETES_SERVICE_PORT: "443"
EOF

sleep 60

kubectl delete pod -n tigera-operator -l k8s-app=tigera-operator

kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF", "hostPorts":null}}}'


kubectl patch ds kube-proxy -n kube-system --patch-file aws-node-delete.yaml

aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-$mycni-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-$mycni-app --preferences MinHealthyPercentage=90,InstanceWarmup=60