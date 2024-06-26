resource "random_string" "s3" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_kms_key" "data_landing_bucket_key" {
  description             = "This key is used to encrypt APPS buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "data_landing_bucket" {
  bucket = "s3-data-landing-${local.naming_suffix}-${random_string.s3.result}"
  # region = data.aws_region.current.name

  lifecycle_rule {
    enabled = true
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_expiration {
      days = 1 
    }
  }

  tags = {
    Name = "s3-data-landing-bucket-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "data_landing_bucket_versioning" {
  bucket = aws_s3_bucket.data_landing_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "data_landing_bucket_logging" {
  bucket        = aws_s3_bucket.data_landing_bucket.id
  target_bucket = var.logging_bucket_id
  target_prefix = "data_landing_bucket/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_landing_bucket_ss_encryption_config" {
  bucket = aws_s3_bucket.data_landing_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.data_landing_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_metric" "data_landing_bucket_logging" {
  bucket = "s3-data-landing-${local.naming_suffix}-${random_string.s3.result}"
  name   = "data_landing_bucket_metric"
}

resource "aws_s3_bucket_policy" "data_landing_bucket" {
  bucket = "s3-data-landing-${local.naming_suffix}-${random_string.s3.result}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "HTTP",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::s3-data-landing-${local.naming_suffix}-${random_string.s3.result}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}

resource "aws_kms_key" "dacc_data_landing_bucket_key" {
  description             = "This key is used to encrypt APPS buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "dacc_data_landing_bucket" {
  bucket = "s3-dacc-data-landing-${local.naming_suffix}-${random_string.s3.result}"
  # region = data.aws_region.current.name

  lifecycle_rule {
    enabled = true
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_expiration {
      days = 1
    }
  }

  tags = {
    Name = "s3-dacc-data-landing-bucket-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "dacc_data_landing_bucket_versioning" {
  bucket = aws_s3_bucket.dacc_data_landing_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "dacc_data_landing_bucket_logging" {
  bucket        = aws_s3_bucket.dacc_data_landing_bucket.id
  target_bucket = var.logging_bucket_id
  target_prefix = "dacc_data_landing_bucket/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dacc_data_landing_bucket_ss_encryption_config" {
  bucket = aws_s3_bucket.dacc_data_landing_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dacc_data_landing_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_metric" "dacc_data_landing_bucket_logging" {
  bucket = "s3-dacc-data-landing-${local.naming_suffix}-${random_string.s3.result}"
  name   = "dacc_data_landing_bucket_metric"
}

resource "aws_s3_bucket_policy" "dacc_data_landing_bucket" {
  bucket = "s3-dacc-data-landing-${local.naming_suffix}-${random_string.s3.result}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "HTTP",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::s3-dacc-data-landing-${local.naming_suffix}-${random_string.s3.result}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}
