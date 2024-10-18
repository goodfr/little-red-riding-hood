# Préparation de votre environnement de lab (administrateur)

> ########################################
> 
> Warning /!\ ceci est un lab, la configuration fournie n'est pas Prod-Ready /!\
> 
> ########################################


```bash
alias cmd_prefix="aws-vault exec sso -- "

cmd_prefix aws sts get-caller-identity

export myarn="<clusteradminarn>"
export mycni="calico"
export currentinstall=$(pwd)

echo -e "### CREATING EKS CLUSTER ### \n"

cd $currentinstall/01-infra/aws

terraform init

terraform workspace select $mycni || terraform workspace new $mycni

cmd_prefix terraform apply -auto-approve  -var adminarn="$myarn"

echo -e "### CHECKING EKS CLUSTER ### \n"

cmd_prefix aws eks update-kubeconfig --region eu-west-1 --name littlered-$mycni

kubectx arn:aws:eks:eu-west-1:955480398230:cluster/littlered-$mycni

cmd_prefix k9s 

echo -e "### INSTALL $mycni CNI ### \n"

cd $currentinstall/01-infra/admin/00-$mycni

cmd_prefix ./install.sh

echo -e "### UPDATE CSI ### \n"

cd $currentinstall/01-infra/admin/01-csi

cmd_prefix ./preprare.sh


echo -e "### INSTALL LB INGRESS ### \n"

cd $currentinstall/01-infra/admin/01-lb

cmd_prefix ./install.sh


echo -e "### INSTALL KYVERNO RULES ### \n"

cd $currentinstall/01-infra/admin/02-kyverno

cmd_prefix ./install.sh


echo -e "### INSTALL VAULT ### \n"

cd $currentinstall/01-infra/admin/03-vault

cmd_prefix ./install.sh

cmd_prefix ./config.sh


echo -e "### PREPARE vcluster ### \n"

cd $currentinstall/01-infra/admin/04-vcluster

cmd_prefix ./download-images.sh

cmd_prefix ./push.sh


echo -e "### INSTALL vcluster ### \n"


cmd_prefix ./newcluster.sh test



cmd_prefix ./create_full.sh

```


```bash


cd $currentinstall/02-demo/01-red-riding-hood-v1/
kubectl label no --all red-archi=enabled
kubectl create ns toto-red
kubectl apply -f static/manifest-red.yaml -n toto-red
kubectl create ns toto-green
kubectl apply -f static/manifest-green.yaml -n toto-green

```