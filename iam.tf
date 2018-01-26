resource "aws_iam_role" "data_ingest_iam_role" {
  name = "data_ingest_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "data_ingest_landing_bucket_policy" {
  name = "data_ingest_landing_bucket_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListObject",
        "s3:DeleteObject"
      ],
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "${aws_kms_key.data_landing_bucket_key.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "data_ingest_landing_bucket" {
  name       = "data_ingest_landing_bucket"
  roles      = ["${aws_iam_role.data_ingest_iam_role.arn}"]
  policy_arn = "${aws_iam_policy.data_ingest_landing_bucket_policy.arn}"
}

resource "aws_iam_instance_profile" "data_ingest_landing_bucket" {
  name = "data_ingest_landing_bucket"
  role = "${aws_iam_role.data_ingest_iam_role.arn}"
}

resource "aws_iam_user" "data_ingest_landing" {
  name = "data_ingest_landing_user"
}

resource "aws_iam_access_key" "data_ingest_landing" {
  user = "${aws_iam_user.data_ingest_landing.name}"
}

resource "aws_iam_user_policy" "data_ingest_landing" {
  name = "data_ingest_landing"
  user = "${aws_iam_user.data_ingest_landing.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    }
  ]
}
EOF
}
