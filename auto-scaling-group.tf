resource "aws_launch_template" "launch-template" {

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-instance-profile.name
  }

  image_id = "ami-059ca4d31bc22f6e4"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  key_name = "main-key"

  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  user_data = filebase64("./ecs.sh")

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }
}


resource "aws_autoscaling_group" "asg" {
  name             = "asg"
  desired_capacity = 3
  max_size         = 3
  min_size         = 3
  # health_check_type         = "EC2"
  # health_check_grace_period = 300
  vpc_zone_identifier = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }

  # target_group_arns     = [aws_lb_target_group.lb-target-group.arn]
  # protect_from_scale_in = true
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.web-cluster.name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}
