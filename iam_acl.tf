resource "aws_iam_group" "acl" {
  name = "iam-group-acl-${local.naming_suffix}"
}

resource "aws_iam_group_membership" "acl" {
  name = "iam-group-membership-acl-${local.naming_suffix}"

  users = [
    "${aws_iam_user.acl.name}",
  ]

  group = "${aws_iam_group.acl.name}"
}

resource "aws_iam_group_policy" "acl" {
  name  = "group-policy-acl-${local.naming_suffix}"
  group = "${aws_iam_group.acl.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListS3Bucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}"
    },
    {
      "Sid": "PutS3Bucket",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Sid": "UseKMSKey",
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

resource "aws_iam_user" "acl" {
  name = "iam-user-acl-${local.naming_suffix}"
}

resource "aws_iam_access_key" "acl" {
  user = "${aws_iam_user.acl.name}"
}
