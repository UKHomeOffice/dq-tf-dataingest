output "data_landing_bucket_arn" {
  value = aws_s3_bucket.data_landing_bucket.arn
}

output "data_landing_bucket_key_arn" {
  value = aws_kms_key.data_landing_bucket_key.arn
}
