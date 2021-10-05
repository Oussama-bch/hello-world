#######################################################
#####      SNS Topic
#######################################################
resource "aws_sns_topic" "hello_world" {
  name = "hello-world-alert-topic"

  tags = {
    Env = "dev"
    Name = "hello-world-alert-topic"
  } 
}

#######################################################
#####      SNS EMAIL Subscriber
#######################################################
resource "aws_sns_topic_subscription" "hello_world" {
  topic_arn = aws_sns_topic.hello_world.arn
  protocol  = "email"
  endpoint  = "${var.email}"
}