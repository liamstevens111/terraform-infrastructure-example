variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "namespace" {
  description = "Name to be used for the current environment, ie example-web-staging or example-web-production"
  type        = string
  default     = "liam-example-staging"
}
