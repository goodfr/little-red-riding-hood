#!/usr/bin/env bash

# --helm-set-string ipam.operator.clusterPoolIPv4PodCIDRList="10.244.0.0/16" \
# --helm-set-string ipam.operator.clusterPoolIPv4MaskSize=24 \
# --helm-set ipv4NativeRoutingCIDR="10.0.0.0/8" \
# --helm-set-string k8s.requireIPv4PodCIDR=true \

kubectl patch ds kube-proxy -n kube-system --patch-file aws-proxy-delete.yaml


cilium install --version v1.13.1 --cluster-name goldielock-cnis-cilium --helm-set-string ipam.mode=kubernetes \
  --helm-set-string enable-ipv4-masquerade=true \
  --helm-set-string ipMasqAgent.enabled=true \
  --helm-set-string bpf.masquerade=true \
  --helm-set-string kubeProxyReplacement=strict \
  --helm-set-string k8sServiceHost=172.20.0.1 \
  --helm-set-string k8sServicePort=443 \
  --helm-set-string ipMasqAgent.config.nonMasqueradeCIDRs='{172.16.0.0/12,192.168.0.0/16}' \
  --helm-set-string ipMasqAgent.config.masqLinkLocal=false \
  --helm-set-string prometheus.enabled=true,operator.prometheus.enabled=true,hubble.enabled=true,hubble.metrics.enableOpenMetrics=true,hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}" \
  --helm-auto-gen-values values.yaml

kubectl create -f ../02-$mycni-monitoring/dashboard.yaml

kubectl apply -f ../02-$mycni-monitoring/monitoring.yaml

kubectl apply -f ../02-$mycni-monitoring/node-exporter.yaml

kubectl apply -f ../02-$mycni-monitoring/kube-state-metrics/examples/standard/


cilium hubble enable --ui

echo "cilium hubble ui"

echo "kubectl -n cilium-monitoring port-forward service/grafana --address 0.0.0.0 --address :: 3000:3000"