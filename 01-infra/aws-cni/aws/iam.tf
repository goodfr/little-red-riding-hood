resource "aws_iam_policy" "lb" {
  name        = "lb_policy"
  path        = "/"
  description = "AWS LoadBalancer policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("policy.json")
}

resource "aws_iam_role" "lb" {
  name               = "lb-controller"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
  managed_policy_arns = [ aws_iam_policy.lb.arn ]
}


data "aws_iam_policy_document" "irsa_assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(module.eks.cluster_oidc_issuer_url,"https://")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(module.eks.cluster_oidc_issuer_url,"https://")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "irsa" {

  role       = aws_iam_role.lb.name
  policy_arn = aws_iam_policy.lb.arn
}

resource "aws_iam_policy" "dns" {
  name        = "external_dns_policy"
  path        = "/"
  description = "AWS Route53 policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("dns-policy.json")
}

resource "aws_iam_role" "dns" {
  name               = "dns-controller"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_dns.json
  managed_policy_arns = [ aws_iam_policy.dns.arn ]
}


data "aws_iam_policy_document" "irsa_assume_role_dns" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(module.eks.cluster_oidc_issuer_url,"https://")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }

    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(module.eks.cluster_oidc_issuer_url,"https://")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "irsa_dns" {

  role       = aws_iam_role.dns.name
  policy_arn = aws_iam_policy.dns.arn
}


