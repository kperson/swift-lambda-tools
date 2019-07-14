resource "aws_dynamodb_table" "pet" {
  name           = "swift_demo_pet"
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
  stream_enabled   = true

  lifecycle {
    ignore_changes = ["read_capacity", "write_capacity"]
  }
}

data "aws_iam_policy_document" "dynamo_pet" {
  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
    ]

    resources = [
      "${aws_dynamodb_table.pet.stream_arn}"
    ]
  }

  statement {
    actions = [
      "dynamodb:ListStreams",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
    ]

    resources = [
      "${aws_dynamodb_table.pet.arn}",
    ]
  }

}
resource "aws_iam_policy" "dynamo_pet" {
  policy = "${data.aws_iam_policy_document.dynamo_pet.json}"
}

resource "aws_iam_role_policy_attachment" "dynamo_pet" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.dynamo_pet.arn}"
}


#hacks, we need to wait until the attachements are complete
data "template_file" "dynamo_pet_table_id" {
  depends_on = [
    "aws_iam_role_policy_attachment.dynamo_pet"
  ]
  template = "$${id}"

  vars = {
    id = "${aws_dynamodb_table.pet.id}"
  }
}

data "template_file" "dynamo_pet_table_stream_arn" {
  depends_on = [
    "aws_iam_role_policy_attachment.dynamo_pet"
  ]
  template = "$${id}"

  vars = {
    id = "${aws_dynamodb_table.pet.stream_arn}"
  }
}
