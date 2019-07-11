locals {
  env = {
    PET_TABLE = "${aws_dynamodb_table.test.id}"
  }
}
