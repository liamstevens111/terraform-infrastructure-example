variable "base_cidr_block" {
  type = string
}

variable "env_name" {
  type        = string
  description = "Name to be used for the current environment, ie staging or production"
}
