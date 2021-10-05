#######################################################
#####      Secret MAnager
#######################################################
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds_secret"
  description = "the RDS postgres psycopg2 connexion secrets"
  recovery_window_in_days = 0
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
#######################################################
#####      Secret Manager Version
#######################################################
resource "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode(
      {
        user = "${var.rds_username}",
        password = "${var.rds_password}",
        host = "${aws_db_instance.postgres_rds_db.address}",
        database = "${aws_db_instance.postgres_rds_db.name}"
    })
}
