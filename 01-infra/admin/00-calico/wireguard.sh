#!/usr/bin/env bash


kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'

aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-calico-app --preferences MinHealthyPercentage=90,InstanceWarmup=60

sleep 180

kubectl get nodes -o yaml | grep -i wireguard