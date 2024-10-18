#!/usr/bin/env bash

kubectl patch ds aws-node -n kube-system --patch-file aws-node-delete.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

kubectl create -f config-calico.yaml

aws autoscaling start-instance-refresh --auto-scaling-group-name littlered-$mycni-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60  --region eu-west-1
aws autoscaling start-instance-refresh --auto-scaling-group-name littlered-$mycni-app --preferences MinHealthyPercentage=90,InstanceWarmup=60  --region eu-west-1
