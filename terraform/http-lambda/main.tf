#Build 

variable "runtime_layers" {
  type = "list"
  default = []
}

variable "build_params" {
  type = "map"
}

variable "env" {
  type    = "map"
  default = {}
}

variable "subnet_ids" {
  type    = "list"
  default = []
}

variable "security_group_ids" {
  type    = "list"
  default = []
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
  default = "30"
}

# HTTP

variable "api_id" {
  type = "string"
}

variable "api_root_resource_id" {
  type = "string"
}

variable "authorization" {
  type    = "string"
  default = "NONE"
}

variable "authorizer_id" {
  type    = "string"
  default = null
}

variable "api_key_required" {
  type    = "string"
  default = null
}

variable "authorization_scopes" {
  type    = "list"
  default = null
}

variable "stage_name" {
  type = "string"
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
    variables = "${var.env}"
  }
}

module "http_pet" {
  source               = "github.com/kperson/terraform-modules//lambda-http-api"
  api_id               = var.api_id
  api_root_resource_id = var.api_root_resource_id
  authorization        = var.authorization
  authorizer_id        = var.authorizer_id
  api_key_required     = var.api_key_required
  authorization_scopes = var.authorization_scopes
  stage_name           = var.stage_name
  lambda_arn           = aws_lambda_function.lambda.arn
}

output "stage" {
  value = module.http_pet.stage
}