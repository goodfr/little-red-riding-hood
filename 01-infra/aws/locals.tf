locals {
  name            = "${var.tale}-${local.env}"
  cluster_version = "1.29"
  region          = "eu-west-1"

  tags = {
    Tales    = local.name
    # GithubRepo = "terraform-aws-eks"
    # GithubOrg  = "terraform-aws-modules"
  }

  env = terraform.workspace
  confs = yamldecode(file("envs/${local.env}.yaml"))
}
