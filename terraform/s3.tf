#######################################################
#####      S3 Bucket
#######################################################
resource "aws_s3_bucket" "elb_access_log" {
  bucket = "${var.s3_name_prefix}-elb-access-log"
  acl    = "private"

  tags = {
    Env = "dev"
    Name = "elb-access-log"
  }  
}

#######################################################
#####      S3 policy
#######################################################
resource "aws_s3_bucket_public_access_block" "elb_access_log" {
  bucket = aws_s3_bucket.elb_access_log.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}