resource "aws_iam_group" "oag" {
  name = "iam-group-oag-${local.naming_suffix}"
}

resource "aws_iam_group_membership" "oag" {
  name = "iam-group-membership-oag-${local.naming_suffix}"

  users = [
    "${aws_iam_user.oag.name}",
  ]

  group = "${aws_iam_group.oag.name}"
}

resource "aws_iam_group_policy" "oag" {
  name  = "group-policy-oag-${local.naming_suffix}"
  group = "${aws_iam_group.oag.id}"

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
        "Resource": [
          "${aws_kms_key.data_landing_bucket_key.arn}",
          "${aws_dynamodb_table.oag.arn}"
        ]
    },
    {
      "Sid": "ListDynamoDBTable",
      "Effect": "Allow",
      "Action": [
        "dynamodb:List*"
      ],
      "Resource": "${aws_dynamodb_table.oag.arn}"
    },
    {
      "Sid": "InteractDynamoDBTable",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchGet*",
        "dynamodb:Get*",
        "dynamodb:BatchWrite*",
        "dynamodb:PutItem"
      ],
      "Resource": "${aws_dynamodb_table.oag.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_user" "oag" {
  name = "iam-user-oag-${local.naming_suffix}"
}

resource "aws_iam_access_key" "oag" {
  user = "${aws_iam_user.oag.name}"
}
