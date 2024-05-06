# Define the provider for AWS
provider "aws" {
  region = "us-east-1"  
}

# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "nodejs-ecs-cluster"  
}

# Create a task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                = "nodejs-family-test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = <<EOF
[
  {
    "name": "nodejs-app-container",
    "image": "smorel237/nodejs-webapp:v1.0.0",  
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
EOF
}

# Create a service to run the task on the cluster
resource "aws_ecs_service" "my_service" {
  name            = "nodejs-app-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-08c54a97347812875"]  
    security_groups  = ["sg-0b702e58ad3103075"]      
    assign_public_ip = true
  }
}

# Create an ecs task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role-nodejs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}