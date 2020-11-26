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

  vpc_config {
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    subnets = ["${data.terraform_remote_state.vpc.private_subnets[0]}"]

    security_group_ids = [
      "sg-09936a2b030e73694",
    ]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/nodejs:10.14.1"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name"  = "ENGINE_API_KEY"
      "value" = "${var.engine_api_key}"
    }

    environment_variable {
      "name"  = "DB_USERNAME"
      "value" = "places"
    }
    
    environment_variable {
      "name"  = "DB_PASSWORD"
      "value" = "${var.db_password}"
    }

    environment_variable {
      "name"  = "DB_DATABASE"
      "value" = "places_to_go"
    }

    environment_variable {
      "name"  = "DB_HOST"
      "value" = "${aws_rds_cluster.places.endpoint}"
    }

    environment_variable {
      "name"  = "NODE_ENV"
      "value" = "development"
    }
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

locals {
  webhook_secret = "${var.webhook_secret}"
}

resource "aws_codepipeline_webhook" "bar" {
  name            = "places_to_go_deploy_webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.places_to_go_deploy.name}"

  authentication_configuration {
    secret_token = "${local.webhook_secret}"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}