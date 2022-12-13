resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_security_group" "alb_ecs_security_group" {
  name        = "alb_ecs_security_group"
  description = "Security group for ECS ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb_ecs_security_group"
  }
}

resource "aws_security_group_rule" "ecs_allow_incoming_http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb_ecs_security_group.id
}

resource "aws_security_group_rule" "ecs_allow_incoming_https" {
  type              = "ingress"
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb_ecs_security_group.id
}

resource "aws_security_group_rule" "outgoing_to_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_ecs_security_group.id
}

resource "aws_lb" "alb_ecs_main" {
  name               = "alb-ecs-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_ecs_security_group.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}
