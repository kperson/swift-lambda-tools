
locals {
  build_params = {
    zip_file      = "${module.build.zip_file}"
    zip_file_hash = "${module.build.zip_file_hash}"
    runtime_layer = "${var.swift_layer}"
    role          = "${data.template_file.role_arn.rendered}"
  }
}


module "dynamo_stream_test" {
  #source = "github.com/kperson/swift-lambda-tools//terraform/dynamo-stream-lambda"
  source        = "../../terraform/dynamo-stream-lambda"
  build_params  = "${local.build_params}"
  env           = "${local.env}"
  function_name = "dynamo_stream_test_event_handler"
  handler       = "com.github.kperson.dynamo.test"
  stream_arn    = "${aws_dynamodb_table.test.stream_arn}"
}
