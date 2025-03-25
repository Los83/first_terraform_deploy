data "aws_iam_policy_document" "policy-document" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "iam-roles" {
  assume_role_policy = data.aws_iam_policy_document.policy-document.json
  name               = "iam-roles"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.iam-roles.name
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.iam-roles.name
}

resource "aws_iam_role_policy_attachment" "ecs-fullaccess-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.iam-roles.name
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = aws_iam_role.iam-roles.name
  role = aws_iam_role.iam-roles.name
}
