resource "aws_ecs_cluster" "cluster" {
  name = "candidate-cluster-${var.region}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_task_definition" "dispatch_task" {

  family                   = "dispatch-task-${var.region}"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "dispatcher"
      image     = "amazon/aws-cli"
      essential = true

      command = [
        "sns",
        "publish",
        "--topic-arn",
        var.sns_topic,
        "--message",
        "{\"email\":\"${var.email}\",\"source\":\"ECS\",\"region\":\"${var.region}\",\"repo\":\"${var.repo_url}\"}"
      ]
    }
  ])
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.dispatch_task.arn
}