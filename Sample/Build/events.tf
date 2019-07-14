
locals {
  build_params = {
    zip_file      = "${module.build.zip_file}"
    zip_file_hash = "${module.build.zip_file_hash}"
    runtime_layer = "${var.swift_layer}"
    role          = "${data.template_file.role_arn.rendered}"
  }
}


module "dynamo_stream_pet_handler" {
  #source = "github.com/kperson/swift-lambda-tools//terraform/dynamo-stream-lambda"
  source        = "../../terraform/dynamo-stream-lambda"
  build_params  = "${local.build_params}"
  env           = "${local.env}"
  function_name = "dynamo_stream_pet_handler"
  handler       = "com.github.kperson.dynamo.pet"
  stream_arn    = "${data.template_file.dynamo_pet_table_stream_arn.rendered}"
}

module "sqs_pet_handler" {
  #source = "github.com/kperson/swift-lambda-tools//terraform/sqs-lambda"
  source        = "../../terraform/sqs-lambda"
  build_params  = "${local.build_params}"
  env           = "${local.env}"
  function_name = "sqs_pet_handler"
  handler       = "com.github.kperson.sqs.pet"
  sqs_arn       = "${data.template_file.sqs_pet_arn.rendered}"
}
