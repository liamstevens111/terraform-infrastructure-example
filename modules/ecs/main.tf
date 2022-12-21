resource "aws_ecr_repository" "main" {
  name = "liam-example-ecr"
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_execution_policy_ssm" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.policydocument.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-ssm-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.policydocument-ssm.arn
}


resource "aws_iam_policy" "policydocument" {
  name   = "tf-policydocument"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_policy" "policydocument-ssm" {
  name   = "tf-policydocument-ssm"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy_ssm.json
}

resource "aws_ecs_cluster" "main" {
  name = "${var.namespace}-cluster"

  tags = {
    Name = "${var.namespace}-ecs"
  }
}

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "${var.namespace}-logs"

  tags = {
    Application = var.namespace
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task-definition" {
  family                   = "liam-example-staging-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn = 

  container_definitions = jsonencode([{
    name      = var.namespace,
    image     = "${aws_ecr_repository.main.repository_url}:${var.tag_name}",
    essential = true,
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs-log-group.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs-liam"
        awslogs-create-group  = "true"
      }
    }
    portMappings = [{
      protocol      = "tcp"
      containerPort = 4000
      hostPort      = 4000
    }],
    environment = [{
      name  = "AWS_S3_BUCKET_NAME",
      value = var.s3_bucket_name
      },
      {
        name  = "PHX_HOST",
        value = "localhost"
      },
      {
        name  = "HEALTH_PATH",
        value = "/_health"
    }],
    secrets = [for secret in var.parameter_store_secrets :
    tomap({ name = secret.name, valueFrom = secret.arn })],
    "cpu" : 256,
    "memory" : 512
  }])
}

resource "aws_ecs_service" "main" {
  name            = "${var.namespace}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.aws-ecs-task-definition.arn
  desired_count   = var.task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.namespace
    container_port   = 4000
  }
}
