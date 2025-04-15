resource "aws_ecs_cluster" "web-cluster" {
  name = "ecs_cluster"
}

resource "aws_ecs_task_definition" "task-definition" {
  family                   = "task-definition"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.iam-roles.arn
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      # image     = "${aws_ecr_repository.repository.repository_url}:latest"
      name      = "web-app"
      image     = "${var.ecr_repository}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : "/ecs/frontend-container",
          "awslogs-region" : "us-east-1"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs-service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.task-definition.arn
  desired_count   = 3


  ## Spread tasks evenly accross all Availability Zones for High Availability
  # ordered_placement_strategy {
  #   type  = "spread"
  #   field = "attribute:ecs.availability-zone"
  # }

  # ## Make use of all available space on the Container Instances
  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "memory"
  # }

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ec2-sg.id]
    # assign_public_ip = true
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb-target-group.arn
    container_name   = "web-app"
    container_port   = 80
  }
  triggers = {
    redeployment = timestamp()
  }

  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  # lifecycle {
  #   ignore_changes = [desired_count]
  # }

  # launch_type = "EC2"
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity-provider.name
    weight            = 1
  }
  depends_on = [aws_autoscaling_group.asg]
}

resource "aws_ecs_capacity_provider" "capacity-provider" {
  name = "tf-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn
    # managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

## is this neeeded
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.web-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.capacity-provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.capacity-provider.name
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "/ecs/frontend-container"
}

resource "aws_security_group" "ec2-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
