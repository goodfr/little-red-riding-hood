resource "boundary_host_static" "kubernetes" {
  type            = "static"
  name            = "eksapi"
  host_catalog_id = boundary_host_catalog_static.kubernetes.id
  address         = "kubernetes.default.svc"
}