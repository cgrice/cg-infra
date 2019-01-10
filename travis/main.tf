terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "travis.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region     = "${var.region}"
}

data "terraform_remote_state" "whichbins" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "whichbins.tfstate"
    region   = "${var.region}"
  }
}

data "terraform_remote_state" "notifications" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "notifications.tfstate"
    region   = "${var.region}"
  }
}

resource "aws_iam_user" "travis" {
  name = "travis-ci"
}

resource "aws_iam_access_key" "travis" {
  user = "${aws_iam_user.travis.name}"
}

resource "aws_iam_user_policy" "travis_deploy_access" {
  name = "travis-deploy-access"
  user = "${aws_iam_user.travis.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:UpdateFunctionCode",
        "s3:PutObject",
        "s3:GetObject",
        "lambda:PublishVersion"
      ],
      "Resource": [
        "${data.terraform_remote_state.whichbins.whichbins_lambda}",
        "arn:aws:s3:::${data.terraform_remote_state.whichbins.whichbins_deploy_bucket}/*",
        "${data.terraform_remote_state.notifications.notifications_lambda}",
        "arn:aws:s3:::${data.terraform_remote_state.notifications.notifications_deploy_bucket}/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}