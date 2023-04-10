![Linkerd](../../images/linkerd_logo.png)

## Installation et configuration de linkerd

Pour faciliter l'installation de kyverno, nous utiliserons l'image
docker de tooling que nous vous avons fourni.


```bash
export REPO_ROOT_DIR=<chemin vers le clone du projet>
export KUBECONFIG=<chemin vers le fichier du config du cluster kubernetes>
docker run --rm -v $KUBECONFIG:/home/tooling/kubeconfig.yaml -v $REPO_ROOT_DIR/labs/:/apps -it -p 50750:50750 ghcr.io/ddrugeon/devoxx2023-tooling
```

Créer votre namespace de travail

```bash
export NAMESPACE=monnamespaceamoi
kubectl create ns $NAMESPACE
```

Vérifier si le cluster est prét pour utilser linkerd:
```bash
linkerd check --pre
```

Installons les CRD ainsi que linkerd sur le cluster
```bash
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
```

Vérifier Linkerd est correctement installé et configuré:
```bash
linkerd check 
```
Linkerd propose un dashboard permettant d'observer les différentes métriques associées à nos déploiements. Celui-ci
n'est pas déployé par défaut. Installons-le sur notre cluster.

```bash
linkerd viz install | kubectl apply -f -
```

Vérifier le dashboard est correctement installé et configuré:
```bash
linkerd check 
```

## Installation et configuration de nos déploiements

Nous allons déployer ensuite le manifeste permettant de créer les ressources du projet à savoir:

- 2 services:
  - goldie-body: exposé uniquement en interne sur le port 9007.
    - /metrics : endpoint prometheus qui sert aussi de liveprobe et readiness probe
    - /images/body.svg pour obtenir l’image de notre personnage
  - little-red-riding-hood-goldie-main: service exposé à l’extérieur via un CLB
    - / : endpoint pour obtenir la page principale de notre service
- 2 déploiements:
  - little-red-riding-hood-goldie-body
  - little-red-riding-hood-goldie-main
- 2 service accounts dédiés:
  - little-red-riding-hood-goldie-body
  - little-red-riding-hood-goldie-main

Déplacer vous dans le dossier 01-red-riding-hood-v1
```bash
cd /apps/01-red-riding-hood-v1/static
```

```bash
kubectl apply -f manifest-red.yaml -n $NAMESPACE
```
---
**Note**: Les politiques mises en place lors de l'étape [Kyverno](../01-kyverno) peuvent empêcher le déploiement.
Modifier la configuration de la politique pour autoriser le déploiement sur le namespace que vous avez choisi
(soit au niveau de la configuration globale de Kyverno soit en modifiant la politique Cluster).
Une fois configuré, appliquer de nouveau la commande
```bash
kubectl apply -f manifest-red.yaml -n $NAMESPACE
```
---

Puis, vérifier que les déploiements s’executent sans aucun problème:

```bash
❯ k -n $NAMESPACE get deploy
```

## Ajout du maillage via linkerd

Vérifier via linkerd que les pods existants sur votre namespace ne sont pas géré par linkerd

```bash
kubectl -n $NAMESPACE get po -o jsonpath='{.items[0].spec.containers[*].name}'
```

Modifions nos déploiements pour ajouter dynamiquement un conteneur sidecar (linkerd proxy)

```bash
kubectl -n $NAMESPACE get deploy -o yaml | linkerd inject - | kubectl apply -n $NAMESPACE -f -
```

Vérifier de nouveau que le dataplane de linkerd a bien été injecté dans nos déploiements.

```bash
kubectl -n $NAMESPACE get po -o jsonpath='{.items[0].spec.containers[*].name}' | grep linkerd-proxy
```

Vérifiez les droits associés à chacune des routes de nos services. Tout le trafic entre nos services est autorisé.

```bash
linkerd viz authz -n $NAMESPACE deploy
```

## Linkerd dashboard

Accédons à l'interface web proposée par le dashboard.

```bash
linkerd viz dashboard --address 0.0.0.0
```

Ouvrir alors le dashboard depuis votre navigateur à l'adresse [http://localhost:50750](http://localhost:50750)

![Dashboard1](./dashboard1.png)

Selectionner votre namespace pour visualiser les différentes statistiques de trafic sur nos déploiements.

![Dashboard2](./dashboard2.png)

Toutes les métriques associées à vos déploiements et pods sont disponibles en temps réel.

Sélectionner le déploiement `little-red-riding-hood-goldie-body`

Puis dans un autre terminal, générer du trafic sur l'ingress

```bash
while sleep 5; do curl http://vcluster-test3-red.aws.sphinxgaia.jeromemasson.fr; done
```

## mTLS

Un des points forts d’un service mesh est la sécurisation des communications via du TLS mutuel sans le gérer dans nos déploiement.

```bash
❯ linkerd viz top deployment/little-red-riding-hood-goldie-body --namespace $NAMESPACE
req id=3:0 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :method=GET :authority=a2716861231d74a4e93dcc828d34d01a-531477736.eu-west-1.elb.amazonaws.com :path=/
rsp id=3:0 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :status=200 latency=1000µs
end id=3:0 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote duration=30µs response-length=564B
req id=3:1 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :method=GET :authority=a2716861231d74a4e93dcc828d34d01a-531477736.eu-west-1.elb.amazonaws.com :path=/parts/body/body.svg
req id=3:2 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true :method=GET :authority=goldie-body:9007 :path=/images/body.svg
req id=3:0 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true :method=GET :authority=goldie-body:9007 :path=/images/body.svg
rsp id=3:0 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true :status=200 latency=1742µs
end id=3:0 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true duration=163µs response-length=15492B
rsp id=3:2 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true :status=200 latency=2740µs
end id=3:2 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true duration=32µs response-length=15492B
rsp id=3:1 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :status=200 latency=3867µs
end id=3:1 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote duration=139µs response-length=15492B
req id=3:3 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :method=GET :authority=a2716861231d74a4e93dcc828d34d01a-531477736.eu-west-1.elb.amazonaws.com :path=/
rsp id=3:3 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :status=200 latency=636µs
end id=3:3 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote duration=83µs response-length=564B
req id=3:4 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :method=GET :authority=a2716861231d74a4e93dcc828d34d01a-531477736.eu-west-1.elb.amazonaws.com :path=/parts/body/body.svg
req id=3:1 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true :method=GET :authority=goldie-body:9007 :path=/images/body.svg
req id=3:5 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true :method=GET :authority=goldie-body:9007 :path=/images/body.svg
rsp id=3:1 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true :status=200 latency=654µs
rsp id=3:5 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true :status=200 latency=1615µs
end id=3:1 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true duration=412µs response-length=15492B
end id=3:5 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true duration=335µs response-length=15492B
rsp id=3:4 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :status=200 latency=2774µs
end id=3:4 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote duration=244µs response-length=15492B
req id=3:6 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :method=GET :authority=a2716861231d74a4e93dcc828d34d01a-531477736.eu-west-1.elb.amazonaws.com :path=/
rsp id=3:6 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :status=200 latency=665µs
end id=3:6 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote duration=65µs response-length=564B
req id=3:7 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :method=GET :authority=a2716861231d74a4e93dcc828d34d01a-531477736.eu-west-1.elb.amazonaws.com :path=/parts/body/body.svg
req id=3:8 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true :method=GET :authority=goldie-body:9007 :path=/images/body.svg
req id=3:2 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true :method=GET :authority=goldie-body:9007 :path=/images/body.svg
rsp id=3:2 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true :status=200 latency=3809µs
end id=3:2 proxy=in  src=10.0.3.26:52356 dst=10.0.2.55:9000 tls=true duration=292µs response-length=15492B
rsp id=3:8 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true :status=200 latency=4808µs
end id=3:8 proxy=out src=10.0.3.26:46142 dst=10.0.2.55:9000 tls=true duration=283µs response-length=15492B
rsp id=3:7 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote :status=200 latency=5975µs
end id=3:7 proxy=in  src=10.0.3.94:65513 dst=10.0.3.26:9000 tls=no_tls_from_remote duration=122µs response-length=15492B
```

Générer du trafic en se connectant sur le load balancer associé et vérifier que certaines routes sont bien protégées en TLS.

Pourquoi certaines routes ne sont-elles pas en TLS ?

Pour de plus amples détails : [https://linkerd.io/2.12/tasks/validating-your-traffic/](https://linkerd.io/2.12/tasks/validating-your-traffic/)

## Restreindre les accès à nos services

Nous pouvons sécuriser les accès à nos services. Dans notre exemple, nous voulons protéger le service goldie-body qui ne doit être accessible que par notre service prinicpal.

### Création d’une nouvelle ressource : le Server

Le server est une ressource spécifique à Linkerd qui décrit les ports spécifiques à nos applications. Une fois que nous aurons déclarés notre Server, seuls les clients autorisés pourront accéder à notre ressource.

Appliquer la définition de notre server goldie-body :

```bash
❯ kubectl apply -n $NAMESPACE -f - <<EOF
---
apiVersion: policy.linkerd.io/v1beta1
kind: Server
metadata:
  name: goldie-body-http
  labels:
    app.kubernetes.io/instance: red-body
    kubernetes.io/instance: body-server
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: little-red-riding-hood-goldie-body
  port: http
  proxyProtocol: HTTP/1
EOF
```

Générer du trafic et visualiser la page de notre goldie. Son image ne s’affiche plus vu que nous n’avons pas autorisé explicitement le flux.

```bash
❯ linkerd viz authz -n $NAMESPACE deploy/little-red-riding-hood-goldie-body
ROUTE    SERVER                       AUTHORIZATION                UNAUTHORIZED  SUCCESS     RPS  LATENCY_P50  LATENCY_P95  LATENCY_P99
default  default:all-unauthenticated  default/all-unauthenticated        0.0rps  100.00%  0.1rps          1ms          1ms          1ms
probe    default:all-unauthenticated  default/probe                      0.0rps  100.00%  0.2rps          1ms          1ms          1ms
default  goldie-body-http                                                0.2rps    0.00%  0.0rps          0ms          0ms          0ms
probe    goldie-body-http             default/probe                      0.0rps  100.00%  0.2rps          1ms          1ms          1ms
```

La route goldie-body-http par défaut n’est plus autorisée.

Nous pouvons autoriser l’accès à notre route uniquement pour les déploiements associés à notre service account. Appliquer la définition suivante:

```bash
kubectl apply -n $NAMESPACE -f - <<EOF
---
apiVersion: policy.linkerd.io/v1beta1
kind: ServerAuthorization
metadata:
  name: goldie-body-http
  labels:
    app.kubernetes.io/instance: red-body
    kubernetes.io/instance: body-server
spec:
  server:
    name: goldie-body-http
  # The voting service only allows requests from the web service.
  client:
    meshTLS:
      serviceAccounts:
        - name: red-little-red-riding-hood-goldie-main
EOF
```

Accédez de nouveau à notre page web, l’image de notre goldie est revenu. Lancer un conteneur supplémentaire qui n’a pas le service account spécifié pour vérifier si la connexion échoue avec un code d’erreur 403

```bash
❯ kubectl run debug --rm -it --image=busybox --restart=Never --command -- wget goldie-body.ddh.svc.cluster.local:9007/images/body.svg
Connecting to goldie-body.ddh.svc.cluster.local:9007 (172.20.193.27:9007)
wget: server returned error: HTTP/1.1 403 Forbidden
pod "debug" deleted
pod default/debug terminated (Error)
```

Pour aller plus loin, nous pouvons aussi refuser toutes les connexions à nos services si aucun server n’est défini. Nous pouvons aussi définir des politiques sur des routes spécifiques pour ajouter automatiquement un timeout, un circuit breaker etc. Pour plus d’infos aller sur la page [https://linkerd.io/2.12/tasks/configuring-per-route-policy/](https://linkerd.io/2.12/tasks/configuring-per-route-policy/)
## Back

[Next Step](../)