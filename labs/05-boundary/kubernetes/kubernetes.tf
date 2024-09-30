provider "kubernetes" {
  config_context_cluster = "arn:aws:eks:eu-west-1:955480398230:cluster/red-riding-hood"
  config_path            = "~/.kube/config"
}
