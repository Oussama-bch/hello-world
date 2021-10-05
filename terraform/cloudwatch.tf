#######################################################
#####      CloudWatch Dashboard
#######################################################
resource "aws_cloudwatch_dashboard" "hello_world_dashboard" {
  dashboard_name = "HelloWorld"
  dashboard_body = <<EOF
  {
  "widgets": [
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ECS",
            "MemoryUtilization",
            "ServiceName",
            "${aws_ecs_service.hello_world_service.name}",
            "ClusterName",
            "${aws_ecs_cluster.hello_world_cluster.name}",
            {
              "color": "#1f77b4"
            }
          ],
          [
            ".",
            "CPUUtilization",
            ".",
            ".",
            ".",
            ".",
            {
              "color": "#9467bd"
            }
          ]

        ],
        "period": 300,
        "region": "${var.aws_region}",
        "title": "Service CPU and Memory Utilization",
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "UnHealthyHostCount",
            "TargetGroup",
            "${aws_lb_target_group.hello_world_target_group.arn_suffix}",
            "LoadBalancer",
            "${aws_lb.hello_world_lb.arn_suffix}",
            {
              "id": "m2",
              "color": "#d62728",
              "stat": "Maximum",
              "period": 1
            }
          ],
          [
            ".",
            "HealthyHostCount",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 1,
              "stat": "Maximum",
              "id": "m3",
              "color": "#98df8a"
            }
          ]
        ],
        "view": "timeSeries",
        "region": "${var.aws_region}",
        "period": 300,
        "stacked": true,
        "title": "Healthy and Unhealthy Service count"
      }
    }
  ]
}
EOF
}

#######################################################
#####      Cloud Watch Metric Alarm
#######################################################
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host_alarm" {
  alarm_name                = "hello-world-alb-unhealthy-host-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "5"
  alarm_description         = "This metric monitors ApplicationELB Unhealthy target group count"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.hello_world.arn]
  ok_actions                = [aws_sns_topic.hello_world.arn]

  dimensions = {
    LoadBalancer = aws_lb.hello_world_lb.arn_suffix
    TargetGroup  = aws_lb_target_group.hello_world_target_group.arn_suffix
  }

  tags = {
    Env = "dev"
    Name = "hello-world-alb-unhealthy-host-alarm"
  } 
}

#######################################################
#####      Cloud Watch Log group
#######################################################
resource "aws_cloudwatch_log_group" "hello_world" {
  name = "hollo-world"
  retention_in_days = 30

  tags = {
    Environment = "dev"
    Application = "hollo-world"
  }
}