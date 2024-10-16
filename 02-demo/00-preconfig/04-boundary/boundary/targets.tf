resource "boundary_target" "insidekind" {
  name         = "eks"
  description  = "local eksapi"
  type         = "tcp"
  default_port = "443"
  scope_id     = boundary_scope.project.id
  host_source_ids = [
    boundary_host_set_static.kubernetes_api.id
  ]
}