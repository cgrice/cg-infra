terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "api.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "blog_api" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "blog-api.tfstate"
    region   = "${var.region}"
  }
}

resource "aws_api_gateway_rest_api" "chrisgrice_com" {
  name        = "chrisgrice.com"
  description = "API for personal websites / tools"
}

resource "aws_api_gateway_resource" "graphql" {
  rest_api_id = "${aws_api_gateway_rest_api.chrisgrice_com.id}"
  parent_id   = "${aws_api_gateway_rest_api.chrisgrice_com.root_resource_id}"
  path_part   = "graphql"
}

resource "aws_api_gateway_method" "graphql" {
  rest_api_id   = "${aws_api_gateway_rest_api.chrisgrice_com.id}"
  resource_id   = "${aws_api_gateway_resource.graphql.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "blog_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.chrisgrice_com.id}"
  resource_id = "${aws_api_gateway_method.graphql.resource_id}"
  http_method = "${aws_api_gateway_method.graphql.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${data.terraform_remote_state.blog_api.blog_api_lambda_invoke}"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_deployment" "live" {
  depends_on = [
    "aws_api_gateway_integration.blog_lambda",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.chrisgrice_com.id}"
  stage_name  = "live"
}


