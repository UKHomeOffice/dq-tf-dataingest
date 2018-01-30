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
