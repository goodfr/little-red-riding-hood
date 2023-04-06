# Install Cilium CNI

## Install CLI

aws-vault exec custom -- aws eks update-kubeconfig --region eu-west-1 --name goldielock-cnis-cilium

kubectx arn:aws:eks:eu-west-1:955480398230:cluster/goldielock-cnis-cilium

aws-vault exec custom -- k9s 


## Install Cilium with the CLI

aws-vault exec  custom -- cilium install --version v1.13.0 --cluster-name goldielock-cnis-cilium --helm-set-string prometheus.enabled=true,operator.prometheus.enabled=true,hubble.enabled=true,hubble.metrics.enableOpenMetrics=true,hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"

aws-vault exec  custom -- kubectl apply -f monitoring.yaml

aws-vault exec custom -- cilium hubble enable --ui

aws-vault exec custom -- cilium hubble ui

aws-vault exec custom -- kubectl -n cilium-monitoring port-forward service/grafana --address 0.0.0.0 --address :: 3000:3000


## Restart nodes if needed

aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-cilium-sys --preferences MinHealthyPercentage=90,InstanceWarmup=60
aws-vault exec custom -- aws autoscaling start-instance-refresh --auto-scaling-group-name goldielock-cnis-cilium-app --preferences MinHealthyPercentage=90,InstanceWarmup=60

## 

https://docs.cilium.io/en/v1.13/gettingstarted/demo/