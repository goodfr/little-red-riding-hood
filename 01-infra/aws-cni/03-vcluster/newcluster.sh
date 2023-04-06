#!/usr/bin/env bash

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: vcluster-$1
  annotations:
    vcluster.loft.sh/created: "true" 
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    external-dns.alpha.kubernetes.io/hostname: vcluster-$1.aws.sphinxgaia.jeromemasson.fr # give your domain name here
  name: vcluster-ingress
  namespace: vcluster-$1
spec:
  ingressClassName: nginx 
  rules:
  - host: vcluster-$1.aws.sphinxgaia.jeromemasson.fr
    http:
      paths:
      - backend:
          service:
            name: $1
            port: 
              number: 443
        path: /
        pathType: ImplementationSpecific
EOF

cat <<EOF > vcluster-$1.yaml
syncer:
  extraArgs:
  - --tls-san=vcluster-$1.aws.sphinxgaia.jeromemasson.fr
EOF

vcluster create $1 -n vcluster-$1 --upgrade --connect=false -f values.yaml -f vcluster-$1.yaml

sleep 10

vcluster connect $1 -n vcluster-$1 --update-current=false --server=https://vcluster-$1.aws.sphinxgaia.jeromemasson.fr

mv kubeconfig.yaml vcluster-$1-kubeconfig.yaml