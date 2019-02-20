terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "dns.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "api" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "api.tfstate"
    region   = "${var.region}"
  }
}

resource "aws_route53_zone" "chrisgrice_com" {
  name = "chrisgrice.com"
}