data "aws_region" "current" {
  current = true
}

data "aws_ami" "di_web" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-data-ingest-server*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_ami" "di_web_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-data-ingest-linux-server*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_ssm_parameter" "data-landing-s3" {
  name = "data-landing-s3"
}

data "aws_ssm_parameter" "data-landing-kms" {
  name = "data-landing-kms"
}
