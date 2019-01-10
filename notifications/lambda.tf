
resource "aws_s3_bucket" "notifications_deploy_bucket" {
  bucket = "cg-notifications-artifacts"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "notifications_config_bucket" {
  bucket = "cg-notifications-config"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "notifications_initial_deploy" {
  bucket = "${aws_s3_bucket.notifications_deploy_bucket.bucket}"
  key    = "deploy.zip"
  source   = "initial_deploy.zip"
  etag   = "${md5(file("initial_deploy.zip"))}"

  lifecycle {
    ignore_changes = ["source", "etag"]
  }
}

resource "aws_s3_bucket_object" "notifications_initial_config" {
  bucket = "${aws_s3_bucket.notifications_config_bucket.bucket}"
  key    = "config.json"
  source   = "config.json"
  etag   = "${md5(file("config.json"))}"

  lifecycle {
    ignore_changes = ["source", "etag"]
  }
}

resource "aws_lambda_function" "notifications_lambda" {
  function_name    = "notifications-lambda"
  role             = "${aws_iam_role.notifications_lambda_role.arn}"
  handler          = "notifications.app.outbound_handler"
  runtime          = "python3.7"
  s3_key           = "${aws_s3_bucket_object.notifications_initial_deploy.id}"
  s3_bucket        = "${aws_s3_bucket.notifications_deploy_bucket.bucket}"

  lifecycle {
    ignore_changes = ["environment.0.variables"]
  }
  environment {
    variables = {
      TWILIO_ACCOUNT_SID = "AC66bc8ffa07e1df424294e3a709cc6b7e"
      TWILIO_MSGSERVICE_SID = "MG728fa6d8044b69303fdfeec86dd97496"
      TWILIO_SENDER = "+441502797324"
      NOTIFICATIONS_CONFIG_BUCKET = "${aws_s3_bucket.notifications_config_bucket.bucket}"
      NOTIFICATIONS_CONFIG_FILE = "${aws_s3_bucket_object.notifications_initial_config.key}"
    }
  }
}