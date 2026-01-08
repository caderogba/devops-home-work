

variable "vpc_id" {
  type        = string
  description = "VPC where ALB will be deployed"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs for ALB"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod) for naming"
}
