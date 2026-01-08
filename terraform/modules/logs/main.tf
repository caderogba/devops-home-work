resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/app-${var.environment}"
  retention_in_days = var.log_retention_days
}
