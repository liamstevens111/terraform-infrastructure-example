variable "namespace" {
  type = string
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}
