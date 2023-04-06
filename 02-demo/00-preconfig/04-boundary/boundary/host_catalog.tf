# resource "boundary_host_catalog_static" "databases" {
#   name        = "databases"
#   description = "Database targets"
#   scope_id = boundary_scope.project.id
# }


resource "boundary_host_catalog_static" "kubernetes" {
  name        = "kubernetes"
  description = "kubernetes catalog"
  scope_id    = boundary_scope.project.id
}
