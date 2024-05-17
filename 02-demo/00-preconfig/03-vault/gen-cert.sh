#!/usr/bin/env bash

# k8s and helm release name
export VAULT_HELM_RELEASE_NAME="vault"
export VAULT_INTERNAL="vault-internal"
export K8S_CLUSTER_NAME="cluster.local"

# generate a keypair
openssl genrsa -out vault.key 2048

# csr config
tee vault-csr.conf <<EOF
[req]
default_bits = 2048
prompt = no
encrypt_key = yes
default_md = sha256
distinguished_name = kubelet_serving
req_extensions = v3_req
[ kubelet_serving ]
O = system:nodes
CN = system:node:*.$VAULT_HELM_RELEASE_NAME.svc.$K8S_CLUSTER_NAME
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.VAULT_INTERNAL
DNS.2 = *.VAULT_INTERNAL.$VAULT_HELM_RELEASE_NAME.svc.$K8S_CLUSTER_NAME
DNS.3 = *.$VAULT_HELM_RELEASE_NAME
IP.1 = 127.0.0.1
EOF
#generate the csr
openssl req -new -key vault.key -out vault.csr -config vault-csr.conf

tee csr.yaml<<EOF 
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: vault.svc
spec:
  signerName: beta.eks.amazonaws.com/app-serving
  request: $(cat vault.csr|base64|tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

kubectl create -f csr.yaml

#approve the csr
kubectl certificate approve vault.svc

#get the crt
kubectl get csr vault.svc -o jsonpath='{.status.certificate}' | openssl base64 -d -A -out vault.crt

kubectl config view\
   --raw \
   --minify \
   --flatten \
   -o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
   | base64 -d > vault.ca
   
# create the tls secret
kubectl create secret generic tls-server\
   -n vault \
   --from-file=server.key=vault.key \
   --from-file=server.crt=vault.crt \
   --from-file=ca.crt=vault.ca