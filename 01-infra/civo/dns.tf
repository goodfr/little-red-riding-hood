# Create a new domain record
data "civo_dns_domain_name" "domain" {
    name = var.dns
}


resource "civo_dns_domain_record" "www" {
    domain_id = data.civo_dns_domain_name.domain.id
    type = "CNAME"
    name = "*"
    value = "${civo_kubernetes_cluster.my-cluster.id}.k8s.civo.com"
    ttl = 600
}