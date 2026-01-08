data "aws_availability_zones" "available" {}


provider "aws" {
  region = var.region
}

module "vpc" {
  source      = "../../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}


module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
}

module "alb" {
  source         = "../../modules/alb"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ecs" {
  source              = "../../modules/ecs"
  environment         = var.environment
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  alb_sg_id           = module.alb.alb_sg_id
  target_group_arn    = module.alb.target_group_arn
  execution_role_arn  = module.iam.task_execution_role_arn
  task_role_arn       = module.iam.task_role_arn
  image               = var.image
  desired_count       = var.desired_count
  cpu                 = var.cpu
  memory              = var.memory
  log_retention_days  = var.log_retention_days
  enable_newrelic     = var.enable_newrelic
  newrelic_secret_arn = var.newrelic_secret_arn
  log_group_name      = module.logs.log_group_name
  newrelic_license_key = var.newrelic_license_key
  task_role_name = module.iam.task_role_name
}


module "ecr" {
  source = "../../modules/ecr"
}

module "logs" {
  source         = "../../modules/logs"
  environment    = var.environment
  retention_days = 30
}

