variable "vpc_name" {
  type = string
}

variable "base_cidr_block" {
  type = string
}

variable "env_name" {
  type        = string
  default     = "prod"
  description = "Name to be used for the current environment, ie staging or production"
}
