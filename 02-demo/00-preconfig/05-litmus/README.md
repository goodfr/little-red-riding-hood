## Preconfig

### Install Litmuschaos AWS

helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm/
helm repo list

aws-vault exec custom -- kubectl create ns litmus

cat <<EOF > override-litmus.yaml
portal:
  server:
    service:
      type: ClusterIP
  frontend:
    service:
      annotations:
        external-dns.alpha.kubernetes.io/hostname: litmus.aws.sphinxgaia.jeromemasson.fr
      tydpe: LoadBalancer
EOF

aws-vault exec custom -- helm upgrade --install chaos litmuschaos/litmus --namespace=litmus -f override-litmus.yaml


### Install Litmuschaos CIVO

helm upgrade --install chaos litmuschaos/litmus --namespace=litmus --set portal.frontend.service.type=NodePort

### Deployed Litmuschaos with ingress

https://docs.litmuschaos.io/docs/user-guides/setup-with-ingress/