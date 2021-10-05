#######################################################
#####      Application ELB
#######################################################
resource "aws_lb" "hello_world_lb" {
  name               = "hello-world-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.elb_access_log.bucket
    prefix  = "hello-world"
    enabled = false
  }

  tags = {
    Env = "dev"
    Name = "hello-world-lb"
  }  
}

#######################################################
#####      ALB target group
#######################################################
resource "aws_lb_target_group" "hello_world_target_group" {
  name     = "hello-world-target-group"
  port     = var.container_conf.port
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
  target_type = "ip"

  health_check {
      enabled  = true
      healthy_threshold = 5
      interval  = 60
      path = "${var.container_conf.health_check}"
      port = "traffic-port"
      protocol = "${var.container_conf.protocol}"
      timeout = 10
      unhealthy_threshold = 10
      matcher = "200"

  }
  tags = {
    Env = "dev"
    Name = "hello-world-target-group"
  }  
}

#######################################################
#####      ALB listener
#######################################################
resource "aws_lb_listener" "hello_world_elb_listener" {
  load_balancer_arn = aws_lb.hello_world_lb.arn
  port              = "${var.container_conf.port}"
  protocol          = "${var.container_conf.protocol}"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello_world_target_group.arn
  }
  tags = {
    Env = "dev"
    Name = "hello-world-target-group"
  }  
}