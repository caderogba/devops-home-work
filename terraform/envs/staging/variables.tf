variable "aws_region" { type = string }

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "image" {
  type = string
}

variable "desired_count" {
  type = number
}
