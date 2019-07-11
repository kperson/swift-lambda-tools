resource "aws_dynamodb_table" "test" {
  name           = "my_test_table"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "userId"
  range_key      = "pet"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "pet"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  stream_view_type = "NEW_AND_OLD_IMAGES"
  stream_enabled = true

  lifecycle {
    ignore_changes = ["read_capacity", "write_capacity"]
  }
}
