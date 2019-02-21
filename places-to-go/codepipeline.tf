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

resource "aws_s3_bucket" "places_to_go_deploy_artifacts" {
  bucket = "codepipeline-places-to-go-artifacts"
  acl    = "private"
  force_destroy = true
}

resource "aws_codebuild_project" "build" {
  name         = "places-to-go-api"
  description  = "Test and deploy the application"
  service_role = "${aws_iam_role.places_to_go_codebuild.arn}"

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/nodejs:10.14.1"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}


resource "aws_codepipeline" "places_to_go_deploy" {
  # Elastic Beanstalk application name and environment name are specified
  name     = "places-to-go"
  role_arn = "${aws_iam_role.places_to_go_codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.places_to_go_deploy_artifacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "cgrice"
        Repo                 = "places-to-go"
        Branch               = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["code"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.build.name}"
      }
    }
  }
}