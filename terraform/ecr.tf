#######################################################
#####      ECR
#######################################################
resource "aws_ecr_repository" "hello_world" {
  name                 = "hello-world"
  image_tag_mutability = "MUTABLE"
  provider = aws.eu_west_3

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Env = "dev"
    Name = "hello-world"
  }  
}