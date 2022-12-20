variable "region" {
  description = "AWS region"
  type        = string
  default     = "staging"
  description = "Name to be used for the current environment, ie staging or production"
}

variable "namespace" {
  description = "Name to be used for the current environment, ie example-web-staging or example-web-production"
  type        = string
  default     = "liam-example-staging"
}

variable "db_password" {
  type = string
}

variable "database_url" {
  type = string
}

variable "secret_key_base" {
  type = string
}
