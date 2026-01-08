locals {
  containers = [
    {
      name      = "app"
      image     = var.image
      essential = true
      portMappings = [{
        containerPort = 8080
      }]
      environment = var.enable_newrelic ? [
        { name = "NEW_RELIC_APP_NAME", value = "java-api-${var.environment}" }
      ] : []
      secrets = var.enable_newrelic ? [
        { name = "NEW_RELIC_LICENSE_KEY", valueFrom = var.newrelic_secret_arn }
      ] : []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]

  # Add New Relic Infrastructure container only if enabled
  nr_container = var.enable_newrelic ? [
    {
      name      = "newrelic-infra"
      image     = "newrelic/infrastructure:latest"
      essential = false
      environment = [
        { name = "NRIA_IS_FORWARD_ONLY", value = "true" },
        { name = "FARGATE", value = "true" }
      ]
      secrets = [
        { name = "NRIA_LICENSE_KEY", valueFrom = var.newrelic_secret_arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "nr-infra"
        }
      }
    }
  ] : []

  all_containers = concat(local.containers, local.nr_container)
}

resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "this" {
  name = "app-${var.environment}-cluster"
}


resource "aws_ecs_task_definition" "this" {
  family                   = "app-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode(local.all_containers)
}


resource "aws_ecs_service" "this" {
  name            = "app-${var.environment}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = 8080
  }

  depends_on = [var.target_group_arn]
}

resource "aws_secretsmanager_secret" "newrelic" {
  name = "newrelic/license-key-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "newrelic" {
  secret_id     = aws_secretsmanager_secret.newrelic.id
  secret_string = var.newrelic_license_key
}

resource "aws_iam_policy" "newrelic_secrets" {
  name = "ecs-newrelic-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.newrelic.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "newrelic" {
  role       = var.task_role_name
  policy_arn = aws_iam_policy.newrelic_secrets.arn
}
/*
container_definitions = jsonencode([
  {
    name  = "app"
    image = var.image
    essential = true

    portMappings = [{
      containerPort = 8080
    }]

    environment = var.enable_newrelic ? [
      {
        name  = "NEW_RELIC_APP_NAME"
        value = "java-api-${var.environment}"
      }
    ] : []

    secrets = var.enable_newrelic ? [
      {
        name      = "NEW_RELIC_LICENSE_KEY"
        valueFrom = var.newrelic_secret_arn
      }
    ] : []
  },

  # --- New Relic Infrastructure Agent ---
  var.enable_newrelic ? {
    name      = "newrelic-infra"
    image     = "newrelic/infrastructure:latest"
    essential = false

    environment = [
      { name = "NRIA_IS_FORWARD_ONLY", value = "true" },
      { name = "FARGATE", value = "true" }
    ]

    secrets = [{
      name      = "NRIA_LICENSE_KEY"
      valueFrom = var.newrelic_secret_arn
    }]
  } : null
])*/

