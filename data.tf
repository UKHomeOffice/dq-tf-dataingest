data "aws_region" "current" {
}

data "aws_ssm_parameter" "data-landing-s3" {
  name = "data-landing-s3"
}

data "aws_ssm_parameter" "data-landing-kms" {
  name = "data-landing-kms"
}

data "aws_ssm_parameter" "ga_bucket" {
  name = "ga_bucket_name"
}

data "aws_ssm_parameter" "ga_bucket_id" {
  name = "gait_access_key"
}

data "aws_ssm_parameter" "ga_bucket_key" {
  name = "gait_secret_key"
}

