# Install Calico CNI

## Install CLI

aws-vault exec custom -- aws eks update-kubeconfig --region eu-west-1 --name goldielock-cnis-calico


kubectx arn:aws:eks:eu-west-1:955480398230:cluster/goldielock-cnis-calico

aws-vault exec custom -- k9s 


## Install Calico with the CLI

aws-vault exec custom -- kubectl patch ds aws-node -n kube-system --patch-file aws-node-delete.yaml


aws-vault exec custom -- kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

aws-vault exec custom -- kubectl create -f config-calico.yaml

aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-app --preferences MinHealthyPercentage=90,InstanceWarmup=60


aws-vault exec custom -- k9s --context arn:aws:eks:eu-west-1:955480398230:cluster/goldielock-cnis-calico

cd ../01-apps

## Modify MTU
aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-app --preferences MinHealthyPercentage=90,InstanceWarmup=60

## Activate wireguard

aws-vault exec custom -- kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'

aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-app --preferences MinHealthyPercentage=90,InstanceWarmup=60

## EBPF


cat <<EOF | aws-vault exec custom -- kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "$(aws-vault exec custom -- kubectl config view --minify -o jsonpath='{.clusters[].cluster.server}' | sed 's#https://##' )"
  KUBERNETES_SERVICE_PORT: "443"
EOF

sleep 60

aws-vault exec custom -- kubectl delete pod -n tigera-operator -l k8s-app=tigera-operator


aws-vault exec custom -- kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF", "hostPorts":null}}}'


aws-vault exec custom -- kubectl patch ds kube-proxy -n kube-system --patch-file aws-node-delete.yaml

aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-app --preferences MinHealthyPercentage=90,InstanceWarmup=60

## Export config

custom
helm show values projectcalico/tigera-operator --version v3.25.0

## unsintall

aws-vault exec custom -- kubectl patch ds aws-node -n kube-system --type=json -p="[{'op': 'remove', 'path': '/spec/template/spec/nodeSelector'}]"
