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
    name      = "liam-hello-world",
    image     = "nginxdemos/hello",
    essential = true,
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
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
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "liam-hello-world"
    container_port   = 80
  }
}
