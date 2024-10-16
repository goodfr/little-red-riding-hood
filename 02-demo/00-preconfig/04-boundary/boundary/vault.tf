provider "vault" {
  # Configuration options
}

resource "vault_token" "boundary" {
  role_name = "app"

  policies = ["boundary-controller"]
  no_default_policy = true

  # orphan
  no_parent = true

  renewable = true
  ttl = "24h"

  period = "20m"

  metadata = {
    "purpose" = "service-account"
  }
}
