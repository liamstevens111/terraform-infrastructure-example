resource "aws_ecr_repository" "main" {
  name = "${var.app_name}-${var.app_name}-ecr"
  tags = {
    Name = "${var.app_name}-ecr"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.env_name}-cluster"

  tags = {
    Name = "${var.app_name}-ecs"
  }
}

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "${var.app_name}-${var.env_name}-logs"

  tags = {
    Application = var.app_name
  }
}

resource "aws_ecs_service" "main" {

  name    = "${var.app_name}-${var.env_name}-ecs-service"
  cluster = aws_ecs_cluster.main.id
  # task_definition = 
  # iam_role = 
  desired_count = var.task_count
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.app_name}-${var.env_name}"
    container_port   = 80
  }

  # depends_on role/alb?

}