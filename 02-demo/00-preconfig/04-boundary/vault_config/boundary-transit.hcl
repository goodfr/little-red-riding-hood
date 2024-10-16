# Transit Key for boundary kms
path "boundary/encrypt/kms" {
  capabilities = ["update"]
}
path "boundary/decrypt/kms" {
  capabilities = ["update"]
}

# token self management
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
 
path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}
