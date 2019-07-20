resource "aws_s3_bucket" "pet" {

  bucket_prefix = "swiftdemopet"

}
data "aws_iam_policy_document" "s3_pet" {

  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.pet.arn}",
      "${aws_s3_bucket.pet.arn}/*"
    ]
  }

}
resource "aws_iam_policy" "s3_pet" {
  policy = "${data.aws_iam_policy_document.s3_pet.json}"
}

resource "aws_iam_role_policy_attachment" "s3_pet" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.s3_pet.arn}"
}
