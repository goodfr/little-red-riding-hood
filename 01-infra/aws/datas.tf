data "aws_caller_identity" "current" {}


data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
  }
}


# User                                            #
###################################################

# Inline policy document 
# data "aws_iam_policy_document" "vault-kms-unseal" {
#   statement {
#     sid       = "VaultKMSUnseal"
#     effect    = "Allow"
#     resources = [aws_kms_key.vault_kms.arn]

#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:DescribeKey",
#     ]
#   }
# }

# Inline policy document 
data "aws_iam_policy_document" "admin_kube" {
  statement {
    sid       = "adminKube"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "eks:*",
      "ecr:*"
    ]
  }
}

# Inline policy document 
data "aws_iam_policy_document" "groups_kube" {
  statement {
    sid       = "groupsKube"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      "ecr:*"
    ]
  }
}

################################################################################
# Supporting Resources
################################################################################


# This policy is required for the KMS key used for EKS root volumes, so the cluster is allowed to enc/dec/attach encrypted EBS volumes
data "aws_iam_policy_document" "ebs" {
  # Copy of default KMS policy that lets you manage it
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Required for EKS
  statement {
    sid = "Allow service-linked role use of the CMK"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}