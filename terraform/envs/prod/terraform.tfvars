environment         = "prod"
region              = "us-east-1"
vpc_cidr            = "10.40.0.0/16"
enable_newrelic     = false
enable_nat_gateway  = false
desired_count       = 1
cpu                 = 256
memory              = 512
log_retention_days  = 3
image               = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest"
newrelic_secret_arn = ""

