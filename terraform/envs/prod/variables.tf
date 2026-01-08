# envs/dev/variables.tf
variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
}

variable "enable_newrelic" {
  type    = bool
  default = false
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "desired_count" {
  type = number
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "log_retention_days" {
  type = number
}

variable "image" {
  type = string
}

variable "newrelic_secret_arn" {
  type    = string
  default = ""
}

variable "newrelic_license_key" {
  type      = string
  sensitive = true
}
