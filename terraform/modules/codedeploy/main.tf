resource "aws_codedeploy_application" "app" {
  compute_platform = "ECS"
  name             = "${var.project_name}-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_application.app.name
  deployment_group_name = "${var.project_name}-deployment-group"
  service_role_arn      = var.service_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_info {
      name = var.target_group_name
    }
  }
}
