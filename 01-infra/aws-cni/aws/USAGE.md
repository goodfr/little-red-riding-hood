# Self Managed Node Groups Example


## Usage

To run this example you need to execute:

```bash
terraform init
terraform workspace select cilium || terraform workspace new cilium
terraform apply -auto-approve

terraform workspace select calico || terraform workspace new calico
terraform apply -auto-approve

terraform workspace select antrea || terraform workspace new antrea
terraform apply -auto-approve

aws eks update-kubeconfig --region eu-west-1 --name cluster-name
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.
