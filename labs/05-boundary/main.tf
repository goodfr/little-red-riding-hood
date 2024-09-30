module "kubernetes" {
  source = "kubernetes"
}

module "boundary" {
  source = "boundary"
  addr   = "http://${module.kubernetes.boundary_loadbalancer}:9200"

}

output "boundary_auth_method_id" {
  value = module.boundary.boundary_auth_method_password
}

output "boundary_connect_syntax" {
  value       = <<EOT

# https://learn.hashicorp.com/tutorials/boundary/oss-getting-started-connect?in=boundary/oss-getting-started

boundary authenticate password -login-name jmasson -auth-method-id ${module.boundary.boundary_auth_method_password}

EOT
  description = "Boundary Authenticate"
}
