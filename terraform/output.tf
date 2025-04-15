output "alb_dns" {
  value = aws_lb.app-lb.dns_name
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.repository.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.web-cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs-service.name
}
