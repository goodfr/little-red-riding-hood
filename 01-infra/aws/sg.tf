
resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = local.tags
}


resource "aws_security_group_rule" "webhook_full" {
  description = "Webhook configuration"
  type              = "ingress"
  from_port         = 1025
  to_port           = 65000
  protocol          = "tcp"
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id = module.eks.node_security_group_id
  
}

# resource "aws_kms_key" "vault_kms" {
#   description             = "Vault-KMS"
#   deletion_window_in_days = 10
# }


# resource "aws_security_group_rule" "webhook_vault" {
#   description = "Vault Injector & Capsule configuration"
#   type              = "ingress"
#   from_port         = 8080
#   to_port           = 8080
#   protocol          = "tcp"
#   source_security_group_id = module.eks.cluster_security_group_id
#   security_group_id = module.eks.node_security_group_id
  
# }

# resource "aws_security_group_rule" "webhook_capsule" {
#   description = "Capsule configuration"
#   type              = "ingress"
#   from_port         = 9443
#   to_port           = 9443
#   protocol          = "tcp"
#   source_security_group_id = module.eks.cluster_security_group_id
#   security_group_id = module.eks.node_security_group_id
  
# }

# resource "aws_security_group_rule" "linkerd_viz_8089" {
#   description              = "Linkerd Viz configuration"
#   type                     = "ingress"
#   from_port                = 8086
#   to_port                  = 8090
#   protocol                 = "tcp"
#   source_security_group_id = module.eks.cluster_security_group_id
#   security_group_id        = module.eks.node_security_group_id
# }

# resource "aws_security_group_rule" "linkerd_viz_8443" {
#   description              = "Linkerd Viz configuration - port 8443"
#   type                     = "ingress"
#   from_port                = 8443
#   to_port                  = 8443
#   protocol                 = "tcp"
#   source_security_group_id = module.eks.cluster_security_group_id
#   security_group_id        = module.eks.node_security_group_id
# }