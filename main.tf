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

  region      = var.region
  namespace   = var.namespace
  environment = var.environment
  tag_name    = var.environment

  task_count = 2

  alb_target_group_arn = module.network.alb_target_group_arn
  #TODO: Replace with private subnet groups when implemented
  subnets         = module.network.public_subnet_ids
  security_groups = [module.network.alb_security_group_id, module.network.ecs_security_group_id]

  s3_bucket_name          = module.s3.bucket_name
  parameter_store_secrets = module.ssm.secrets
}

module "rds" {
  source                 = "./modules/db"
  db_name                = "liamdbstaging"
  db_password            = var.db_password
  namespace              = var.namespace
  subnet_ids             = module.network.public_subnet_ids
  vpc_security_group_ids = [module.network.rds_security_group_id]
}

module "s3" {
  source      = "./modules/s3"
  namespace   = var.namespace
  bucket_name = "main"
}

module "ssm" {
  source = "./modules/ssm"

  environment = var.environment
  parameters = {
    "/${var.environment}/DATABASE_URL" : var.database_url,
    "/${var.environment}/REDIS_ENDPOINT_ADDRESS" : module.elasticache.primary_endpoint_address,
    "/${var.environment}/SECRET_KEY_BASE" : var.secret_key_base
  }
}

module "elasticache" {
  source = "./modules/elasticache"

  namespace = var.namespace
  #TODO: Replace with private subnet groups when implemented
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.network.elasticache_security_group_id]
}
