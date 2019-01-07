resource "aws_dynamodb_table" "oag" {
  name         = "oag-dynamodb-table-${local.naming_suffix}"
  hash_key     = "FileID"
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption = {
    enabled = true
  }

  point_in_time_recovery = {
    enabled = true
  }

  attribute {
    name = "FileID"
    type = "S"
  }

  tags = {
    Name = "oag-dynamodb-table-${local.naming_suffix}"
  }
}
