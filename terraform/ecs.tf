#######################################################
#####      ECS Fargate Cluster
#######################################################
resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello-world"
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Env = "dev"
    Name = "hello-world"
  }  
}

#######################################################
#####      ECS Fargate Task Definition
#######################################################
resource "aws_ecs_task_definition" "hello_world_task" {
  family                    = "hello-world-task"
  requires_compatibilities  = ["${var.ecs_type}"]
  memory                    = var.container_conf.memory
  cpu                       = var.container_conf.cpu
  task_role_arn             =  aws_iam_role.ecs_task_role.arn
  execution_role_arn        = aws_iam_role.ecs_task_role.arn
  network_mode              =  "awsvpc"

  container_definitions     = jsonencode([
    {
      name      = "hello-world"
      image     = "${aws_ecr_repository.hello_world.repository_url}:${var.container_conf.tag}"
      memory    = "${var.container_conf.memory}"
      essential = true
      "environment": [
        {
          "name": "${var.ecs_type}",
          "value": "TRUE"
        },
        {
          "name": "SECRETMANAGER",
          "value": "${aws_secretsmanager_secret.rds_secret.name}"
        },
        {
          "name": "AWS_REGION",
          "value": "${var.aws_region}"
      }
      ],
      portMappings = [
        {
          containerPort = "${var.container_port}"
          hostPort      = "${var.container_port}"
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.hello_world.name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
          }
      }
    }
  ]
  )

  tags = {
    Env   = "dev"
    Name  = "hello-world-task"
  } 
}

#######################################################
#####      ECS Fargate Service
#######################################################
resource "aws_ecs_service" "hello_world_service" {
  name            = "hello-world-service"
  launch_type     = "${var.ecs_type}"
  cluster         = aws_ecs_cluster.hello_world_cluster.id
  task_definition = aws_ecs_task_definition.hello_world_task.arn
  desired_count   = 3

  network_configuration {
      subnets = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]
      security_groups = [aws_security_group.fargate_sg.id]
      assign_public_ip = true
}

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world_target_group.arn
    container_name   = "hello-world"
    container_port   = "${var.container_port}"
  }

  tags = {
    Env = "dev"
    Name = "hello-world-service"
  } 

}