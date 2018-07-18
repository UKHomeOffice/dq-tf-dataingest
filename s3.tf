resource "random_string" "s3" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_kms_key" "data_landing_bucket_key" {
  description             = "This key is used to encrypt APPS buckets"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "data_landing_bucket" {
  bucket = "s3-data-landing-${local.naming_suffix}-${random_string.s3.result}"
  region = "${data.aws_region.current.name}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.data_landing_bucket_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${var.logging_bucket_id}"
    target_prefix = "data_landing_bucket/"
  }

  tags = {
    Name = "s3-data-landing-bucket-${local.naming_suffix}"
  }
}

resource "aws_kms_key" "dacc_data_landing_bucket_key" {
  description             = "This key is used to encrypt APPS buckets"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "dacc_data_landing_bucket" {
  bucket = "s3-dacc-data-landing-${local.naming_suffix}-${random_string.s3.result}"
  region = "${data.aws_region.current.name}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.dacc_data_landing_bucket_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${var.logging_bucket_id}"
    target_prefix = "dacc_data_landing_bucket/"
  }

  tags = {
    Name = "s3-dacc-data-landing-bucket-${local.naming_suffix}"
  }
}
