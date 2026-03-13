resource "aws_ecs_cluster" "cluster" {
  name = "candidate-cluster-${var.region}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs_task" {
  name        = "ecs-task-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow outbound traffic to SNS"
  
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.dispatch_task.arn
}
