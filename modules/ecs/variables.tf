variable "namespace" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "task_count" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "database_url" {
  type = string
}

variable "secret_key_base" {
  type = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tag_name" {
  type = string
}
