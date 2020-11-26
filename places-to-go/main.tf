terraform {
  backend "s3" {
    bucket = "cg-infra-tfstate"
    key = "plaes-to-go.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region     = "${var.region}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "vpc.tfstate"
    region   = "${var.region}"
  }
}




module "places_lambda_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "places-lambda-sg"
  description = "Default SG for prod VPC"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"   
}

module "places_to_go_lambda" {
  source = "../modules/lambda"
  name = "places-to-go"
  handler = "dist/lambda.graphqlHandler"
  runtime = "nodejs8.10"
  timeout = 8
  region = "${var.region}"
  account_id = "${var.account_id}"
  env_vars = {
    NODE_ENV = "prod"
    DB_USERNAME = "places"
    DB_PASSWORD = "${var.db_password}"
    DB_HOST = "${aws_rds_cluster.places.endpoint}"
    DB_DATABASE = "places_to_go"
  }
  subnet_ids = ["${data.terraform_remote_state.vpc.private_subnets[0]}"]
  security_group_ids = ["${module.places_lambda_sg.this_security_group_id}"]
}
