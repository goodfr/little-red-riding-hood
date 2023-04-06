#!/usr/bin/env bash

kubectl apply --validate=false -f cert-manager.yaml --wait

sleep 30

kubectl apply -f v2_4_7_full.yaml --wait

kubectl apply -f v2_4_7_ingclass.yaml

kubectl apply -f ingress-nginx-controller.yaml

# Trick to prepare LB
kubectl apply -f manifest-red.yaml