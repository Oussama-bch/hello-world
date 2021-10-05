#######################################################
#####      RDS Postgres DB
#######################################################
resource "aws_db_instance" "postgres_rds_db" {
  allocated_storage    = 50
  storage_type         = "standard"
  engine               = "postgres"
  engine_version       = "13.2"
  instance_class       = "db.m5.xlarge"
  name                 = "postgres_rds_db"
  identifier           = "postgres-rds-db"
  username             = var.rds_username
  password             = var.rds_password

  final_snapshot_identifier = false
  publicly_accessible  = true
  
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_grp.name

  tags = {
    Environment = "dev"
    Name        = "postgres_rds_db"
  }
}

#######################################################
#####      RDS subnet group
#######################################################
resource "aws_db_subnet_group" "rds_subnet_grp" {
  name       = "rds-subnet-grp"
  subnet_ids = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id,aws_default_subnet.default_az3.id]

  tags = {
    Environment = "dev"
    Name        = "rds_subnet_grp"
  }
}

