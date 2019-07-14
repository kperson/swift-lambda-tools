resource "aws_sqs_queue" "pet" {
  name                       = "swift_demo_pet"
  visibility_timeout_seconds = "180"
}
data "aws_iam_policy_document" "sqs_pet" {

  statement {
    actions = [
      "sqs:*"
    ]
    resources = [
      "${aws_sqs_queue.pet.arn}",
    ]
  }

}
resource "aws_iam_policy" "sqs_pet" {
  policy = "${data.aws_iam_policy_document.sqs_pet.json}"
}

resource "aws_iam_role_policy_attachment" "sqs_pet" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.sqs_pet.arn}"
}


#hacks, we need to wait until the attachements are complete
data "template_file" "sqs_pet_arn" {
  depends_on = [
    "aws_iam_role_policy_attachment.sqs_pet"
  ]
  template = "$${id}"

  vars = {
    id = "${aws_sqs_queue.pet.arn}"
  }
}



data "template_file" "sqs_pet_id" {
  depends_on = [
    "aws_iam_role_policy_attachment.sqs_pet"
  ]
  template = "$${id}"

  vars = {
    id = "${aws_sqs_queue.pet.id}"
  }
}
