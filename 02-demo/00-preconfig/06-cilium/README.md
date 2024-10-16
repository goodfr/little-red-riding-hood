# Cilium Install


## Delete VPC CNI if already installed

```bash
kubectl -n kube-system patch daemonset aws-node --type='strategic' -p='{"spec":{"template":{"spec":{"nodeSelector":{"io.cilium/aws-node-enabled":"true"}}}}}'

kubectl get po -n kube-system

```

### Install cilium with helm

Add HELM repo

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
```

Install CNI

```bash
helm install cilium cilium/cilium --version 1.15.6 \
  --namespace kube-system \
  --set egressMasqueradeInterfaces=eth0 \
  --set nodePort.enabled=true \
  -f values.yaml
```

Check install


```bash
cilium status --wait
```

Test

```bash
cilium connectivity test
```

## Install Hubble observability


```bash
helm upgrade cilium cilium/cilium --version 1.15.6 \
    --namespace kube-system \
    --reuse-values \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true
```

Check install

``bash
cilium hubble ui
```

## Activate service mesh

```bash
helm upgrade cilium cilium/cilium --version 1.15.6 \
    --namespace kube-system \
    --reuse-values \
    --set envoyConfig.enabled=true
```

```bash
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
```