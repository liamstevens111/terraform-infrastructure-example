variable "app_name" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "env_name" {
  type = string
}

variable "service_name" {
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
