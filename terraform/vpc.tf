#######################################################
#####      Default VPC
#######################################################
resource "aws_default_vpc" "default" {
   tags = {
     Name = "DEFAULT VPC"
   }
}

#######################################################
#####      Default subnet AZ1
#######################################################
resource "aws_default_subnet" "default_az1" {
  availability_zone = "eu-west-3a"

  tags = {
    Name = "Default subnet for eu-west-3a"
  }
}
#######################################################
#####      Default subnet AZ2
#######################################################
resource "aws_default_subnet" "default_az2" {
  availability_zone = "eu-west-3b"

  tags = {
    Name = "Default subnet for eu-west-3b"
  }
}
#######################################################
#####      Default subnet AZ3
#######################################################
resource "aws_default_subnet" "default_az3" {
  availability_zone = "eu-west-3c"

  tags = {
    Name = "Default subnet for eu-west-3c"
  }
}

