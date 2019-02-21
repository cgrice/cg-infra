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
