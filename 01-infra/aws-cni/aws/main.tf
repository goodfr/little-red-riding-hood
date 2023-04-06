################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true


  aws_auth_users = concat([ for u in aws_iam_user.admins: {
    userarn = u.arn
    username = u.name
    groups   = ["system:masters"]
  }])

  cluster_addons = local.confs.cluster_addons

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  self_managed_node_group_defaults = {
    create_security_group = false

    # enable discovery of autoscaling groups by cluster-autoscaler
    # autoscaling_group_tags = {
    #   "k8s.io/cluster-autoscaler/enabled" : true,
    #   "k8s.io/cluster-autoscaler/${local.name}" : "owned",
    # }
    bootstrap_extra_args = <<-EOT
    # The admin host container provides SSH access and runs with "superpowers".
    # It is disabled by default, but can be disabled explicitly.
    [settings.host-containers.admin]
    enabled = false

    # The control host container provides out-of-band access via SSM.
    # It is enabled by default, and can be disabled if you do not expect to use SSM.
    # This could leave you with no way to access the API and change settings on an existing node!
    [settings.host-containers.control]
    enabled = true

    [settings.kubernetes.node-labels]
    "goldie" = "enabled"
    ingress = "allowed"

    [settings.kubernetes.node-taints]
    "node.cilium.io/agent-not-ready" = "true:NoExecute"
    EOT
  }

  self_managed_node_groups = {
    # Default node group - as provisioned by the module defaults
    # default_node_group = {}

    # Bottlerocket node group
    # bottlerocket = {
    #   name = "bottlerocket-eks"

    #   platform      = "bottlerocket"
    #   ami_id        = data.aws_ami.eks_default_bottlerocket.id
    #   instance_type = "t3.medium"
    #   desired_size  = 2
    #   key_name      = aws_key_pair.this.key_name

    #   iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

    #   bootstrap_extra_args = <<-EOT
    #   # The admin host container provides SSH access and runs with "superpowers".
    #   # It is disabled by default, but can be disabled explicitly.
    #   [settings.host-containers.admin]
    #   enabled = false

    #   # The control host container provides out-of-band access via SSM.
    #   # It is enabled by default, and can be disabled if you do not expect to use SSM.
    #   # This could leave you with no way to access the API and change settings on an existing node!
    #   [settings.host-containers.control]
    #   enabled = true

    #   [settings.kubernetes.node-labels]
    #   ingress = "allowed"
    #   EOT
    # }
    
    # "${local.name}" node group
    "${local.name}-sys" = {
      name = "${local.name}-sys"
      use_name_prefix = false

      platform      = "linux"
      ami_id        = data.aws_ami.eks_default.id
      instance_type = "t3.small"
      desired_size  = 2
      key_name      = aws_key_pair.this.key_name

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
        aws_iam_policy.lb.arn
      ]

      bootstrap_extra_args = local.confs.bootstrap_extra_args_sys

      post_bootstrap_user_data = local.confs.post_bootstrap_user_data
    }  

    "${local.name}-app" = {
      name = "${local.name}-app"
      use_name_prefix = false

      platform      = "linux"
      ami_id        = data.aws_ami.eks_default.id
      instance_type = "t3.medium"
      desired_size  = 2
      key_name      = aws_key_pair.this.key_name

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
        aws_iam_policy.lb.arn
      ]

      bootstrap_extra_args = local.confs.bootstrap_extra_args

      post_bootstrap_user_data = local.confs.post_bootstrap_user_data

    }   
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.confs.cidr

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = slice(cidrsubnets(local.confs.cidr, 8, 8, 8, 8, 8, 8), 0, 3)
  public_subnets  = slice(cidrsubnets(local.confs.cidr, 8, 8, 8, 8, 8, 8), 3, 6)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
