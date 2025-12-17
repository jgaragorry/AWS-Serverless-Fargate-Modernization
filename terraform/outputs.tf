output "alb_dns_name" {
  description = "URL Pública del Balanceador de Carga"
  value       = "http://${aws_lb.app_lb.dns_name}"
}

output "ecr_repo_url" {
  value = var.app_image
}
