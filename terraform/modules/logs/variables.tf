variable "environment" {
  type        = string
  description = "Environment name"
}

variable "retention_days" {
  type        = number
  default     = 7
}
variable "log_retention_days" {
    default     = 30
}
