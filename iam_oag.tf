resource "aws_iam_group" "oag_put" {
  name = "iam-group-oag-put-${local.naming_suffix}"
}

resource "aws_iam_group_membership" "oag_put" {
  name = "iam-group-membership-oag-put-${local.naming_suffix}"

  users = [
    "${aws_iam_user.oag_put.name}",
  ]

  group = "${aws_iam_group.oag_put.name}"
}

resource "aws_iam_group_policy" "oag_put" {
  name  = "oag-put-group-policy-${local.naming_suffix}"
  group = "${aws_iam_group.oag_put.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}"
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
        ],
        "Resource": "${aws_kms_key.data_landing_bucket_key.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_user" "oag_put" {
  name = "iam-user-oag-put-${local.naming_suffix}"
}

resource "aws_iam_access_key" "oag_put" {
  user = "${aws_iam_user.oag_put.name}"
}
