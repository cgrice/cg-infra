terraform {
    backend "s3" {
      bucket = "cg-infra-tfstate"
      key = "notifications.tfstate"
      region = "eu-west-1"
    }
}

provider "aws" {
  region     = "${var.region}"
}
