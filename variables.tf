variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "env_name" {
  type        = string
  default     = "prod"
  description = "Name to be used for the current environment, ie staging or production"
}

variable "app_name" {
  type    = string
  default = "liam-example"
}
