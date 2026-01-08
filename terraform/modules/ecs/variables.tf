variable "environment" {
  type        = string
  description = "Environment name (dev/prod) for naming resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC where ECS is deployed"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for ECS tasks"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID to allow ingress"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "task_role_name" {
  type        = string
  description = "ECS task role name"
}

variable "image" {
  type        = string
  description = "Docker image URI"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks"
}

variable "cpu" {
  type        = number
  description = "Task CPU units"
}

variable "memory" {
  type        = number
  description = "Task memory (MB)"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention in days"
}

variable "enable_newrelic" {
  type        = bool
  default     = false
  description = "Whether to enable New Relic monitoring"
}

variable "newrelic_secret_arn" {
  type        = string
  default     = ""
  description = "ARN of New Relic secret in Secrets Manager"
}

variable "region" {
  type        = string
  description = "AWS region for logs and resources"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for ECS tasks"
}
/*
variable "enable_newrelic" {
  type    = bool
  default = false
}*/

variable "newrelic_license_key" {
  type      = string
  sensitive = true
}



