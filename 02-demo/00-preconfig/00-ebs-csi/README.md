aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"trust.json"

  aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name AmazonEKS_EBS_CSI_DriverRole


```bash
IRSA_ROLE="AmazonEKS_EBS_CSI_DriverRole"
aws iam create-role --role-name $IRSA_ROLE --assume-role-policy-document file://trust.json
aws iam attach-role-policy --role-name $IRSA_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

```bash

ROLE_ARN=$(aws iam get-role --role-name $IRSA_ROLE --query Role.Arn --output text)

# Add annotation referencing IRSA role
kubectl patch serviceaccount "ebs-csi-controller-sa" --namespace kube-system --patch \
 "{\"metadata\": { \"annotations\": { \"eks.amazonaws.com/role-arn\": \"$ROLE_ARN\" }}}"

```