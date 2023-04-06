# Préparation de votre poste utilisateur

> ########################################
> 
> Warning /!\ ceci est un lab, la configuration fournie n'est pas Prod-Ready /!\
> 
> ########################################

Pour ce labs, vous devez :
  [ ] Configurer votre shell
    [ ] Avoir votre shell configurer avec des tokens pour AWS et un rôle vous permettant de créer VPC et autres configurations nécessaire pour votre/cos clusters EKS  
  [ ] Installer des binaires
    [ ] Installer Terraform: `>= 0.13.1`
    [ ] Installer la CLI cilium : https://docs.cilium.io/en/v1.13/gettingstarted/k8s-install-default/#install-the-cilium-cli
    [ ] Installer HELM
  [ ] Configurer l'environnement de Terraform
    [ ] Mettre à jour les fichiers YAML en accord avec votre environnement `01-infra/aws/envs/...yaml`
    [ ] la partie CIDR doit être un /16 au risque de voir les configurations en place poser des soucis
  [ ] Niveau connexion internet
    [ ] ëtre dans la capacité de vous connecter sur des ports exotiques
  


```bash
alias cmd_prefix="aws-vault exec custom -- "

cmd_prefix aws sts get-caller-identity


export mycni="calico"
export currentinstall=$(pwd)

cmd_prefix aws sts get-caller-identity

echo -e "### CREATING EKS CLUSTER ### \n"

cd $currentinstall/01-infra/aws-cni/aws

terraform workspace select $mycni || "terraform init && terraform workspace new $mycni"

cmd_prefix terraform apply -auto-approve

echo -e "### CHECKING EKS CLUSTER ### \n"

cmd_prefix aws eks update-kubeconfig --region eu-west-1 --name goldielock-cnis-$mycni

kubectx arn:aws:eks:eu-west-1:955480398230:cluster/goldielock-cnis-$mycni

cmd_prefix k9s 

echo -e "### INSTALL $mycni CNI ### \n"

cd $currentinstall/01-infra/aws-cni/00-$mycni

cmd_prefix ./install.sh

echo -e "### INSTALL LB INGRESS ### \n"

cd $currentinstall/01-infra/aws-cni/00-lb

cmd_prefix ./install.sh

cd $currentinstall/01-infra/aws-cni/00-kyverno

cmd_prefix ./install.sh

cd $currentinstall/01-infra/aws-cni/02-trivy-scanner

cmd_prefix ./install.sh


echo -e "### INSTALL vcluster ### \n"

cd $currentinstall/01-infra/aws-cni/03-vcluster

cmd_prefix ./prepare.sh


cmd_prefix ./newcluster.sh test

```


```bash


cd $currentinstall/02-demo/01-red-riding-hood-v1/
kubectl label no --all red-archi=enabled
kubectl create ns toto-red
kubectl apply -f static/manifest-red.yaml -n toto-red
kubectl create ns toto-green
kubectl apply -f static/manifest-green.yaml -n toto-green

```