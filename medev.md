# Dev et debug de la formation

pb1 : cluster up

```sh
export MONCLUSTER="22" # et non 12 car pb mise en ligne des clusters

docker container run -it --rm ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest -c "curl -s    --request POST     --data '{\"password\":\"vcluster-app$MONCLUSTER\"}' http://vault.aws.sphinxgaia.jeromemasson.fr/v1/auth/userpass/login/vcluster-app$MONCLUSTER | jq -r .auth.client_token" > montoken-vault.txt
```

pb2: DNS --> retour sur cluster 12 maintenant up

```sh
export MONCLUSTER="12"
export node_name_var=ip-10-1-2-97.eu-west-1.compute.internal

kubectl label nodes $node_name_var red-archi=enabled
```

> Pour spec.ingress.host. Remplacer vcluster-test-red.aws.sphinxgaia.jeromemasson.fr par l'URL de votre cluster Kubernetes dédié à savoir vcluster-app<number>-red.aws.sphinxgaia.jeromemasson.fr

>> regarder le service ingress (dernier service du yaml)

solution

```markdown
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr" # vcluster-test-red.aws.sphinxgaia.jeromemasson.fr # give your domain name here
spec:
  ingressClassName: nginx 
  rules:
    - host: "vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr" 
```

```sh
curl -H "Host: vcluster-app<number>-red.aws.sphinxgaia.jeromemasson.fr" http://vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr
```

> /!\ pour la démo on passe root -u 0

```sh
# la base est ok
docker run --rm -v $KUBECONFIG:/home/tooling/.kube/config -v $REPO_ROOT_DIR/labs:/apps/labs -it ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest

# -u 0 OK
docker run --user root --rm -v $KUBECONFIG:/home/tooling/.kube/config -v $REPO_ROOT_DIR/labs:/apps/labs -it ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest

export KUBECONFIG=/home/tooling/.kube/config

kubectl cluster-info

curl -H "Host: vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr" http://vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr

dig vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr +short
```

> on ajoute l'ip qui va bien dans le DNS

```sh
vim /etc/hosts

52.51.105.30 vcluster-app12-red.aws.sphinxgaia.jeromemasson.fr
```