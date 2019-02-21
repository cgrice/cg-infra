terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "school_run.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region     = "${var.region}"
}

variable "env_vars" {
  default = {
    SCHOOL_RUN_FROM = "Chicago",
    SCHOOL_RUN_TO = "New York",
    SCHOOL_RUN_ALTERNATIVE_VIA = "Boston",
    SCHOOL_RUN_ALTERNATIVE_NAME = "Boston",
  }
}

module "school_run_lambda" {
  source = "../modules/lambda"
  name = "school-run"
  handler = "school_run.app.lambda_handler"
  runtime = "python3.7"
  timeout = 8
  region = "${var.region}"
  account_id = "${var.account_id}"
  env_vars = "${var.env_vars}"
}
