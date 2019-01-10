terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "whichbins.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region     = "${var.region}"
}

resource "aws_s3_bucket" "whichbins_deploy_bucket" {
  bucket = "whichbins-artifacts"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "whichbins_config_bucket" {
  bucket = "whichbins-config"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "whichbins_initial_deploy" {
  bucket = "${aws_s3_bucket.whichbins_deploy_bucket.bucket}"
  key    = "deploy.zip"
  source   = "initial_deploy.zip"
  etag   = "${md5(file("initial_deploy.zip"))}"

  lifecycle {
    ignore_changes = ["source", "etag"]
  }
}



resource "aws_lambda_function" "whichbins_lambda" {
  function_name    = "whichbins-lambda"
  role             = "${aws_iam_role.whichbins_lambda_role.arn}"
  handler          = "whichbins.app.lambda_handler"
  runtime          = "python3.7"
  s3_key           = "${aws_s3_bucket_object.whichbins_initial_deploy.id}"
  s3_bucket        = "${aws_s3_bucket.whichbins_deploy_bucket.bucket}"

  environment {
    variables = {
      WHICHBINS_CONFIG_BUCKET = "${aws_s3_bucket.whichbins_config_bucket.bucket}"
      WHICHBINS_CONFIG_FILE = "bins.json"
    }
  }
}