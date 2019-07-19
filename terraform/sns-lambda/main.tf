#Build 

variable "build_params" {
  type = "map"
}

variable "env" {
  type    = "map"
  default = {}
}

# Common
variable "function_name" {
  type = "string"
}

variable "handler" {
  type = "string"
}

# Common Custom
variable "memory_size" {
  type    = "string"
  default = "256"
}

variable "timeout" {
  type    = "string"
  default = "180"
}

# SNS

variable "topic_arn" {
  type = "string"
}

variable "raw_message_delivery" {
  type    = "boolean"
  default = null
}

variable "filter_policy" {
  type    = "string"
  default = null
}

variable "delivery_policy" {
  type    = "string"
  default = null
}

resource "aws_lambda_function" "lambda" {
  filename         = "${var.build_params["zip_file"]}"
  function_name    = "${var.function_name}"
  role             = "${var.build_params["role"]}"
  handler          = "${var.handler}"
  runtime          = "provided"
  memory_size      = "${var.memory_size}"
  timeout          = "${var.timeout}"
  publish          = true
  layers           = ["${var.build_params["runtime_layer"]}"]
  source_code_hash = "${var.build_params["zip_file_hash"]}"

  environment {
    variables = "${var.env}"
  }
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn            = "${var.topic_arn}"
  protocol             = "lambda"
  endpoint             = "${aws_lambda_function.lambda.arn}"
  raw_message_delivery = "${var.raw_message_delivery}"
  filter_policy        = "${var.filter_policy}"
  delivery_policy      = "${var.delivery_policy}"
}
