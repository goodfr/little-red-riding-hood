output "boundary_loadbalancer" {
  value = data.kubernetes_service.boundary.status.0.load_balancer.0.ingress.0.hostname
}