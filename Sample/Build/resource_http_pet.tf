resource "aws_api_gateway_rest_api" "pet" {
  name = "pet_api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
