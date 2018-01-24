resource "aws_iam_policy" "data_ingest_ec2_landing_bucket" {
  name = "data_ingest_ec2_landing_bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${var.data_landing_bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${var.data_landing_bucket}/*"]
    }
  ]
}
EOF
}

# resource "aws_iam_policy" "data_ingest_ec2_landing_bucket_decrypt" {
#   name = "data_ingest_ec2_landing_bucket_decrypt"
#
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": {
#     "Effect": "Allow",
#     "Action": [
#       "kms:Decrypt"
#     ],
#     "Resource": ["${aws_kms_key.bucket_key.arn}"]
#   }
# }
# EOF
# }

resource "aws_iam_policy_attachment" "data_ingest_ec2_landing_bucket" {
  name       = "data_ingest_ec2_landing_bucket"
  roles      = ["${aws_iam_role.data_ingest_iam_role.arn}"]
  policy_arn = "${aws_iam_policy.data_ingest_ec2_landing_bucket.arn}"
}

# resource "aws_iam_policy_attachment" "data_ingest_ec2_landing_bucket_decrypt" {
#   name       = "data_ingest_ec2_landing_bucket_decrypt"
#   roles      = ["${aws_iam_role.data_ingest_iam_role.arn}"]
#   policy_arn = "${aws_iam_policy.data_ingest_ec2_landing_bucket_decrypt.arn}"
# }

resource "aws_iam_instance_profile" "data_ingest_ec2_landing_bucket" {
  name = "data_ingest_ec2_landing_bucket"
  role = "${aws_iam_role.data_ingest_iam_role.arn}"
}
