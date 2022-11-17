# Install trivy scanner

helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update


aws-vault exec custom -- kubectl create ns trivy-system
aws-vault exec custom -- helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.6.0


aws-vault exec custom -- k9s

check vuln and configaudit