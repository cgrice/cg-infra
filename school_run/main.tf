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

resource "aws_s3_bucket" "school_run_deploy_bucket" {
  bucket = "school-run-artifacts"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "school_run_initial_deploy" {
  bucket = "${aws_s3_bucket.school_run_deploy_bucket.bucket}"
  key    = "deploy.zip"
  source   = "initial_deploy.zip"
  etag   = "${md5(file("initial_deploy.zip"))}"

  lifecycle {
    ignore_changes = ["source", "etag"]
  }
}

resource "aws_lambda_function" "school_run_lambda" {
  function_name    = "school-run-lambda"
  role             = "${aws_iam_role.school_run_lambda_role.arn}"
  handler          = "school_run.app.lambda_handler"
  runtime          = "python3.7"
  s3_key           = "${aws_s3_bucket_object.school_run_initial_deploy.id}"
  s3_bucket        = "${aws_s3_bucket.school_run_deploy_bucket.bucket}"
  timeout          = "8"

  lifecycle {
    ignore_changes = ["environment.0.variables"]
  }
  environment {
    variables = {
      SCHOOL_RUN_FROM = "Chicago",
      SCHOOL_RUN_TO = "New York",
      SCHOOL_RUN_ALTERNATIVE_VIA = "Boston",
      SCHOOL_RUN_ALTERNATIVE_NAME = "Boston",
    }
  }
}