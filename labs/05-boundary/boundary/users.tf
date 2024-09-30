resource "boundary_user" "user" {
  for_each    = var.users
  name        = each.key
  description = "User resource for ${each.key}"
  account_ids = [boundary_account_password.user[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_user" "admins" {
  for_each    = var.admins
  name        = each.key
  description = "admins resource for ${each.key}"
  account_ids = [boundary_account_password.admins[each.value].id]
  scope_id    = boundary_scope.org.id
}
