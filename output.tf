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
