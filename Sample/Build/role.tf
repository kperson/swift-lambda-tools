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


#hack, we need to wait until the attachements are complete
data "template_file" "role_arn" {
  depends_on = [
    "aws_iam_role_policy_attachment.log"
  ]
  template = "$${arn}"

  vars = {
    arn = "${aws_iam_role.lambda.arn}"
  }
}
