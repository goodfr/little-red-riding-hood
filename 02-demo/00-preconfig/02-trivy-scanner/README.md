# Install trivy scanner

helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update

helm search repo trivy-operator -l

kubectl create ns trivy-system
helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.22.1

kubectl apply -f tests/test.yaml

kubectl get po -n trivy-system -w 

kubectl get vuln -n red

kubectl get configaudit -n red

kubectl get rbacassessmentreports -n red
