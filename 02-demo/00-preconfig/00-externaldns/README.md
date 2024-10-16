# Install external-dns

## Install

```bash
kubectl create ns external-dns
```

```bash
kubectl apply -n external-dns -f external-dns.yaml
```

## Configure IAM role

``` bash
ACCOUNT_ID=$(aws sts get-caller-identity \
  --query "Account" --output text)
OIDC_PROVIDER=$(aws eks describe-cluster --name red-riding-hood \
  --query "cluster.identity.oidc.issuer" --output text | sed -e 's|^https://||')

cat <<-EOF > trust.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "$OIDC_PROVIDER:sub": "system:serviceaccount:external-dns:external-dns",
                    "$OIDC_PROVIDER:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF
``` 

```bash
IRSA_ROLE="external-dns-irsa-role"
aws iam create-role --role-name $IRSA_ROLE --assume-role-policy-document file://trust.json
aws iam attach-role-policy --role-name $IRSA_ROLE --policy-arn arn:aws:iam::955480398230:policy/external_dns_policy
```

```bash

ROLE_ARN=$(aws iam get-role --role-name $IRSA_ROLE --query Role.Arn --output text)

# Add annotation referencing IRSA role
kubectl patch serviceaccount "external-dns" --namespace external-dns --patch \
 "{\"metadata\": { \"annotations\": { \"eks.amazonaws.com/role-arn\": \"$ROLE_ARN\" }}}"

```