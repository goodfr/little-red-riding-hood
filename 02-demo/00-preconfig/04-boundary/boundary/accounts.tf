resource "random_password" "userpass" {
  for_each         = var.users
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "boundary_account_password" "user" {
  for_each       = var.users
  name           = lower(each.key)
  description    = "Account password for ${each.key}"
  auth_method_id = boundary_auth_method_password.password.id
  type           = "password"
  login_name     = lower(each.key)
  password       = random_password.userpass[each.key].result
}