#!/usr/bin/env bash

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: little-red-riding-hood-goldie
  namespace: vcluster-test
  annotations:
    external-dns.alpha.kubernetes.io/hostname: toto.aws.sphinxgaia.jeromemasson.fr # give your domain name here
spec:
  ingressClassName: nginx 
  rules:
    - host: "vcluster-test-toto.aws.sphinxgaia.jeromemasson.fr"
      http:
        paths:
          - path: /*
            pathType: ImplementationSpecific
            backend:
              service:
                name: red-little-red-riding-hood-goldie-main
                port:
                  number: 80
  tls:
  - hosts: 
    - red.aws.sphinxgaia.jeromemasson.fr
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: little-red-riding-hood-goldie
  namespace: vcluster-test
  annotations:
    external-dns.alpha.kubernetes.io/hostname: toto.aws.sphinxgaia.jeromemasson.fr # give your domain name here
spec:
  ingressClassName: nginx 
  rules:
    - host: "toto.aws.sphinxgaia.jeromemasson.fr"
      http:
        paths:
          - path: /*
            pathType: ImplementationSpecific
            backend:
              service:
                name: red-little-red-riding-hood-goldie-main
                port:
                  number: 80
  tls:
  - hosts: 
    - red.aws.sphinxgaia.jeromemasson.fr
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: little-red-riding-hood-goldie
  namespace: vcluster-test
  annotations:
    external-dns.alpha.kubernetes.io/hostname: vcluster-test-toto.aws.sphinxgaia.jeromemasson.fr # give your domain name here
spec:
  ingressClassName: nginx 
  rules:
    - host: "toto.aws.sphinxgaia.jeromemasson.fr"
      http:
        paths:
          - path: /*
            pathType: ImplementationSpecific
            backend:
              service:
                name: red-little-red-riding-hood-goldie-main
                port:
                  number: 80
  tls:
  - hosts: 
    - red.aws.sphinxgaia.jeromemasson.fr
EOF