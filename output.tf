output "vpc_id_consumable" {
  value       = aws_vpc.tech_challenge_vpc.id
  description = "This is the VPC ID for later use"
}

output "private_subnet_1_id" {
  value       = aws_subnet.tech_challenge_private_subnet_1.id
}

output "private_subnet_2_id" {
  value       = aws_subnet.tech_challenge_private_subnet_2.id
}

output "public_subnet_1_id" {
  value       = aws_subnet.tech_challenge_public_subnet_1.id
}

output "public_subnet_2_id" {
  value       = aws_subnet.tech_challenge_public_subnet_2.id
}


output "app_name" {
  value = kubernetes_service.api_service.metadata[0].name
}

output "load_balancer_hostname" {
  value = data.kubernetes_service.api_service_data.status[0].load_balancer[0].ingress[0].hostname
}
