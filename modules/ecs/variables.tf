variable "namespace" {
  type = string
}

variable "environment" {
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

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tag_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "parameter_store_secrets" {
  type = set(object({
    name = string
    arn  = string
  }))
}
