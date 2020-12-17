#Build 

variable "runtime_layers" {
  type    = list(string)
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
  type    = string
  default = "180"
}

# CloudWatch

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "schedule_expression" {
  type = string
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

resource "aws_cloudwatch_event_rule" "rule" {
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = aws_cloudwatch_event_rule.rule.name
  arn  = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "lambda_permission" {
  depends_on =  [aws_lambda_function.lambda]
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}