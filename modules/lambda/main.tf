

resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "${var.name}-artifacts"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "initial_deploy" {
  bucket = "${aws_s3_bucket.deploy_bucket.bucket}"
  key    = "deploy.zip"
  source   = "${path.module}/initial_deploy.zip"
  etag   = "${md5(file("${path.module}/initial_deploy.zip"))}"

  lifecycle {
    ignore_changes = ["source", "etag"]
  }
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${var.name}-lambda"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "${var.handler}"
  runtime          = "${var.runtime}"
  s3_key           = "${aws_s3_bucket_object.initial_deploy.id}"
  s3_bucket        = "${aws_s3_bucket.deploy_bucket.bucket}"
  timeout          = "${var.timeout}"

  lifecycle {
    ignore_changes = ["environment.0.variables"]
  }

  environment {
    variables = "${var.env_vars}"
  }

  vpc_config {
    subnet_ids = ["${var.subnet_ids}"]
    security_group_ids = ["${var.security_group_ids}"]
  }
}