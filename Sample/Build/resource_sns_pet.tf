resource "aws_sns_topic" "pet" {
  name = "swift_demo_pet"
}
data "aws_iam_policy_document" "sns_pet" {

  statement {
    actions = [
      "sns:*"
    ]
    resources = [
      "${aws_sns_topic.pet.arn}"
    ]
  }

}
resource "aws_iam_policy" "sns_pet" {
  policy = "${data.aws_iam_policy_document.sns_pet.json}"
}

resource "aws_iam_role_policy_attachment" "sns_pet" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.sns_pet.arn}"
}
