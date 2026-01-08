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

/*
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}

resource "aws_ecr_repository" "app" {
  name = "java-rest-api"
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow ALB to reach ECS tasks"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound (via NAT or VPC endpoints)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS inbound from internet"
  vpc_id      = aws_vpc.this.id

  #HTTP
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/java-api"
  retention_in_days = 14
}
*/