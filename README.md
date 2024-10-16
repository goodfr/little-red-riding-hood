# CONF: Le petit Chaperon rouge se met enfin au Zero Trust

## EDITO

Au travers du conte, pour enfant, je revisite le petit chaperon rouge: notre petite goldie rouge va voir sa mère-grand dans la maison de captain kube !!!

Et si notre petite application se décidait enfin à pratiquer le Zero Trust quand elle va voir sa mère-grand et que la maison de captain Kube était aussi sécurisée !!!

Nous aborderons les risques encourues lors d'un déploiement d'une application Kubernetes et d'un environnement non sécurisé.

Plan:

Accès au cluster avec Boudary
- authentification
- droits & rôles
Déploiement de l'application
- vérification déploiement avec Kyverno
- vérification de l'image in-cluster avec Trivy
- Gestion des secrets avec Vault

## Setup infra

[ ] [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

[ ] Create your cluster


### Create CIVO cluster

```bash
export CIVO_TOKEN=$(cat ~/.civo_token)



```

### Create AWS cluster


### Play sequences

asciinema play replay/2021/01-infra-aws --speed 4

asciinema play replay/2021/00-preconfig-kyverno --speed 4
asciinema play replay/2021/00-preconfig-trivy --speed 2
asciinema play replay/2021/00-preconfig-vault --speed 2
asciinema play replay/2021/00-preconfig-boundary --speed 2
asciinema play replay/2021/01-demo-apps 
asciinema play replay/2021/02-demo-apps