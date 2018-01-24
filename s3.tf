resource "aws_kms_key" "data_landing_bucket_key" {
  description             = "This key is used to encrypt APPS buckets"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "data_landing_bucket" {
  bucket = "${var.s3_bucket_name}"
  acl    = "${var.s3_bucket_acl}"
  region = "${var.region}"

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

  tags = {
    Name = "s3-data-landing-bucket-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_policy" "data_landing_bucket_policy" {
  bucket = "${aws_s3_bucket.data_landing_bucket.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "s3:ListBucket",
      "Resource": ["${aws_s3_bucket.data_landing_bucket.arn}"]
    },
    {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": ["${aws_s3_bucket.data_landing_bucket.arn}/*"]
    }
  ]
}
EOF
}
