s3_name_prefix    = "hello-world"
rds_username = "USERNAME"
rds_password = "PASSWORD"
email ="youremail@mail.com"


#######################################################
#####      Container Runtime config
#######################################################
container_conf = {
  tag   = "latest",
  port  = 80,
  memory= 2048,
  cpu   = 1024,
  health_check = "/healthz",
  protocol = "HTTP"
  }




