terraform {
  cloud {
    organization = "liamstevens111"

    workspaces {
      name = "liam-infrastructure-example"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source          = "./modules/network"
  base_cidr_block = "10.0.0.0/16"

  namespace = var.namespace
}

module "ecs" {
  source = "./modules/ecs"

  namespace  = var.namespace
  task_count = 2

  alb_target_group_arn = module.network.alb_target_group_arn
  subnets              = module.network.private_subnet_ids
  security_groups      = [module.network.alb_security_group_id, module.network.ecs_security_group_id]
}

module "ecs" {
  source = "./modules/ecs"

  alb_target_group_arn = module.network.alb_target_group_arn
  subnets              = module.network.private_subnet_group_ids
  security_groups      = [module.network.alb_security_group_id, module.network.ecs_security_group_id]
}

module "ecs" {
  source = "./modules/ecs"

  alb_target_group_arn = module.network.alb_target_group_arn
  subnets              = module.network.private_subnet_group_ids
  security_groups      = [module.network.alb_security_group_id, module.network.ecs_security_group_id]
}
