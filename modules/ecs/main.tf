resource "aws_ecr_repository" "main" {
  name = "${var.app_name}-${var.app_name}-ecr"
  tags = {
    Name = "${var.app_name}-ecr"
  }
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:GetLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
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


resource "aws_iam_policy" "policydocument" {
  name   = "tf-policydocument"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json

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
  family                   = "liam-hello-world"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([{
    name = "liam-example-prod-ecr",
    # image     = "${aws_ecr_repository.main.repository_url}:latest",
    image     = "301618631622.dkr.ecr.us-east-1.amazonaws.com/liam-example-ecr:latest",
    essential = true,
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs-log-group.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs-liam"
        awslogs-create-group  = "true"
      }
    }
    portMappings = [{
      protocol      = "tcp"
      containerPort = 4000
      hostPort      = 4000
    }],
    # Sensitive vars such as database_url to be replaced by parameter store
    environment = [{
      name  = "DATABASE_URL",
      value = var.database_url
      },
      {
        name  = "SECRET_KEY_BASE",
        value = var.secret_key_base
      },
      {
        name  = "PHX_HOST",
        value = "localhost"
      },
      {
        name  = "HEALTH_PATH",
        value = "/_health"
    }],
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
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "liam-example-prod-ecr"
    container_port   = 4000
  }

  # depends_on role/alb?

}
