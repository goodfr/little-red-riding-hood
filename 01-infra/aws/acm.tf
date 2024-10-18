resource "aws_acm_certificate" "cert" {
  domain_name       = "*.aws.sphinxgaia.jeromemasson.fr"
  validation_method = "DNS"

  tags = {
    Environment = "devfest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "jm" {
  name         = "aws.sphinxgaia.jeromemasson.fr"
  private_zone = false
}

resource "aws_route53_record" "final" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.jm.zone_id
}