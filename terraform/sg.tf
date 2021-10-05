#######################################################
#####      Get my IP address
#######################################################
data "http" "my_public_ip" {
    url = "https://ifconfig.co/json"
    request_headers = {
      Accept = "application/json"
    }
}
locals {
    ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}

#######################################################
#####      ELB SG
#######################################################
resource "aws_security_group" "elb_sg" {
    vpc_id      = aws_default_vpc.default.id
    name        = "elb-sg"
    description = "Application Load Balancer SG"
    
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
     Name = "elb-sg"
   }
}

#######################################################
#####      Fargate SG
#######################################################
resource "aws_security_group" "fargate_sg" {
    vpc_id      = aws_default_vpc.default.id
    name        = "fargate-sg"
    description = "Fargate tasks SG"
    
    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      security_groups = [aws_security_group.elb_sg.id]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
     Name = "fargate-sg"
   }
}
#######################################################
#####      RDS SG
#######################################################
resource "aws_security_group" "rds_security_group" {
  name = "rds-security-group"
  description = "RDS security group"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Allow PostgreSQL from Fargate security group"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups =  [aws_security_group.fargate_sg.id]
  }
  
  ingress {
    description = "Allow All internal TCP traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self = true 
  }

  ingress {
      description = "Allow PostgreSQL from my IP"
      from_port = 5432
      to_port = 5432
      protocol    = "tcp"
      cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    }

  egress {
    description = "Allow All egress traffic"
    from_port = 0
    to_port = 0 
    protocol = "-1" # any
    cidr_blocks = ["0.0.0.0/0" ]
  }

  tags = {
    Environment = "dev"
    Name = "rds-security-group"
  }
}