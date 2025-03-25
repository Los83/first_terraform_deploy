resource "aws_lb" "app-lb" {
  enable_deletion_protection = false
  internal                   = false
  load_balancer_type         = "application"
  name                       = "app-lb"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = module.vpc.public_subnets
  tags = {
    Name = "ecs-alb"
  }
}
resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }
}
resource "aws_lb_target_group" "lb-target-group" {
  # target_type = "instance"
  target_type = "ip"
  name        = "lb-target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 20
    # matcher             = 200
    protocol = "HTTP"
  }
}
resource "aws_security_group" "lb" {
  name   = "allow-web-lb"
  vpc_id = data.aws_vpc.main.id

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
