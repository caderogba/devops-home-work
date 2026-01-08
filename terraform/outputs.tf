output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
