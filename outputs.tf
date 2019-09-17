output "data_ingest_landing_user_arn" {
  value = "${aws_iam_user.data_ingest_landing.arn}"
}

output "data_landing_bucket_arn" {
  value = "${aws_s3_bucket.data_landing_bucket.arn}"
}

output "data_landing_bucket_key_arn" {
  value = "${aws_kms_key.data_landing_bucket_key.arn}"
}

output "rds_mds_address" {
  value = "${aws_db_instance.mds_postgres.address}"
}
