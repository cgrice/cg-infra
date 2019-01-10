provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.state_bucket}"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "terraform"
    prefix  = "terraform/"
    enabled = true

    noncurrent_version_expiration {
      days = "30"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
