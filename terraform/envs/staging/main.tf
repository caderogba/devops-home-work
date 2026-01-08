data "aws_availability_zones" "available" {}


provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"
  cidr   = var.vpc_cidr
}

module "iam" {
  source = "../../modules/iam"
  environment = var.environment
}

module "alb" {
  source         = "../../modules/alb"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ecs" {
  source             = "../../modules/ecs"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  image         = var.image
  desired_count = var.desired_count

  cluster_name = "app-${var.environment}-cluster"
  service_name = "app-${var.environment}-service"
  task_family  = "app-${var.environment}-task"
}
