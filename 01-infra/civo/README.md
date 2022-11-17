## Create CIVO infra


export CIVO_TOKEN=$(cat ~/.civo_token)

terraform apply -auto-approve
export KUBECONFIG=$(pwd)/kubeconfig