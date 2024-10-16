resource "boundary_credential_store_vault" "vault" {
  name        = "vault"
  description = "My first Vault credential store!"
  address     = "http://vault.vault.svc:8200"      # change to Vault address
  token       = vault_token.boundary # change to valid Vault token
  scope_id    = boundary_scope.project.id
}