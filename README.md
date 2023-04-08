# CONF: Le petit Chaperon rouge se met enfin au Zero Trust

## EDITO

Au travers du conte, pour enfant, je revisite le petit chaperon rouge: notre petite goldie rouge va voir sa mère-grand dans la maison de captain kube !!!

Et si notre petite application se décidait enfin à pratiquer le Zero Trust quand elle va voir sa mère-grand et que la maison de captain Kube était aussi sécurisée !!!

Nous aborderons les risques encourues lors d'un déploiement d'une application Kubernetes et d'un environnement non sécurisé.

## Sommaire

Au programme, nous allons:

Accèder au cluster avec Boudary
- authentification
- droits & rôles
Déployer l'application 
- vérification déploiement avec Kyverno
- vérification de l'image in-cluster avec Trivy
- Gestion des secrets avec Vault


Pour réaliser ces différentes opération, nous allons vous founir :
* Un nom de cluster kubernetes qui vous sera util pour obtenir le nom de domaine
* Un container Docker contenant tous les outils 
* Un context Kubernetes sur un cluster isolé
* TODO:
** Une Url vers un Vault pour récupérer le context Kube de votre cluster Kubernetes
** UN token Vault

## Préambule pour jouer les différents labs

### Obtenir les outils

Ce hands on Zero trust utilise beaucoup d'outils (Trivy, Linkerd, Vault, Terraform, Kyberno, ...).
Afin de ne pas emcombrer vos postes, nous vous proposons un container d'outillage qui contient l'ensemble des outils.

#### Le container de tooling

Sur mac/Arm :
```bash
docker pull zebeurton/lab-devoxx/tooling
```

TODO : Donner la commande Vault pour récupérer le context Kube

Sur amd64

```bash
docker pull zebeurton/lab-devoxx/tooling:amd
```

## Ouvrons le livre

Pour vous lancer dans l'aventure, vous pouvez vous rendre sur (labs)[/labs]

## Troubleshooting

Si vous rencontrez des difficultés, vous pourriez trouver une solution

TODO A compléter

