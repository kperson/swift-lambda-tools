# Task Role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log" {

  statement {
    actions = [
      "logs:*",
    ]

    resources = [
      "*",
    ]
  }

}
data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
    ]

    resources = [
      "${aws_dynamodb_table.test.stream_arn}"
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
      "${aws_dynamodb_table.test.arn}",
    ]
  }

}



resource "aws_iam_role" "lambda" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}


resource "aws_iam_policy" "log" {
  policy = "${data.aws_iam_policy_document.log.json}"
}

resource "aws_iam_role_policy_attachment" "log" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.log.arn}"
}

resource "aws_iam_policy" "dynamo" {
  policy = "${data.aws_iam_policy_document.dynamo.json}"
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.dynamo.arn}"
}



#hack, we need to wait until the attachements are complete
data "template_file" "role_arn" {
  depends_on = [
    "aws_iam_role_policy_attachment.dynamo",
    "aws_iam_role_policy_attachment.log",
  ]
  template = "$${arn}"

  vars = {
    arn = "${aws_iam_role.lambda.arn}"
  }
}
