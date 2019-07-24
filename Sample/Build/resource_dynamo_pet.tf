module "dynamo_pet" {
  source           = "github.com/kperson/terraform-modules//auto-scaled-dynamo"
  table_name       = "swiftdemopet"
  hash_key         = "userId"
  range_key        = "pet"
  stream_view_type = "NEW_AND_OLD_IMAGES"
  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "pet"
      type = "S"
    }
  ]

}

module "dynamo_pet_policy" {
    source    = "github.com/kperson/terraform-modules//dynamo-crud-policy"
    table_arn = "${module.dynamo_pet.arn}"
    stream_arn = "${module.dynamo_pet.stream_arn}"
}



resource "aws_iam_role_policy_attachment" "dynamo_pet" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${module.dynamo_pet_policy.arn}"
}
