#Build 

variable "runtime_layers" {
  type = list(string)
  default = []
}

variable "build_params" {
  type = map(string)
}

variable "env" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

# Common
variable "function_name" {
  type = string
}

variable "handler" {
  type = string
}

# Common Custom
variable "memory_size" {
  type    = string
  default = "256"
}

variable "timeout" {
  type    = "string"
  default = "180"
}

# SNS

variable "topic_arn" {
  type = string
}

variable "filter_policy" {
  type    = string
  default = null
}

variable "delivery_policy" {
  type    = string
  default = null
}


resource "aws_lambda_function" "lambda" {
  filename         = var.build_params["zip_file"]
  function_name    = var.function_name
  role             = var.build_params["role"]
  handler          = var.handler
  runtime          = "provided"
  memory_size      = var.memory_size
  timeout          = var.timeout
  publish          = true
  layers           = var.runtime_layers
  source_code_hash = var.build_params["zip_file_hash"]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = var.env
  }
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.topic_arn
}

resource "aws_sns_topic_subscription" "lambda" {
  depends_on      = ["aws_lambda_permission.lambda"]
  topic_arn       = var.topic_arn
  protocol        = "lambda"
  endpoint        = aws_lambda_function.lambda.arn
  filter_policy   = "var.filter_policy
  delivery_policy = "var.delivery_policy
}
