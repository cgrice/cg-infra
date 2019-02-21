terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "blog-api.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region = "${var.region}"
}

variable "env_vars" {
  default = {
    ENABLE_TRACING = "true",
  }
}

module "cg_api_lambda" {
  source = "../modules/lambda"
  name = "cg-api"
  handler = "dist/lambda.graphqlHandler"
  runtime = "nodejs8.10"
  timeout = 4
  region = "${var.region}"
  account_id = "${var.account_id}"
  env_vars = "${var.env_vars}"
}


