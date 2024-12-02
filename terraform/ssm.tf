resource "aws_ssm_parameter" "db_username" {
  name  = "/cloudtalents/startup/db_user"
  value = var.db_username
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/cloudtalents/startup/db_password"
  value = var.db_password
  type  = "String"
}

resource "aws_ssm_parameter" "db_secret_key" {
  name  = "/cloudtalents/startup/secret_key"
  value = var.secret_key
  type  = "String"
}

resource "aws_ssm_parameter" "database_endpoint" {
  name  = "/cloudtalents/startup/database_endpoint"
  value = aws_db_instance.rds_postgres.address
  type  = "String"
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = "/cloudtalents/startup/image_storage_bucket_name"
  value = aws_s3_bucket.startup_image_bucket.id
  type  = "String"
}

resource "aws_ssm_parameter" "cloudfront_domain" {
  name  = "/cloudtalents/startup/image_storage_cloudfront_domain"
  value = aws_cloudfront_distribution.cf_s3_distribution.domain_name
  type  = "String"
}
