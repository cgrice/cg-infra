resource "aws_iam_role" "places_to_go_codepipeline" {
  name = "codepipeline-places-to-go"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "places_to_go_codebuild" {
  name = "codebuild-places-to-go"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "codepipeline_artifact_access" {
  statement {
    sid = ""

    actions = [
      "s3:*",
    ]

    resources = [
        "${aws_s3_bucket.places_to_go_deploy_artifacts.arn}",
        "${aws_s3_bucket.places_to_go_deploy_artifacts.arn}/*"
    ]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "codepipeline_places_access" {
  statement {
    sid = ""

    actions = [
      "codebuild:*",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "codebuild_places_access" {
  statement {
    sid = ""

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvent",
      "logs:PutLogEvents",
    ]

    resources = [
        "*"
    ]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "codepipeline_artifact_access" {
  name   = "codepipeline-places-to-go-artifact-access"
  policy = "${data.aws_iam_policy_document.codepipeline_artifact_access.json}"
}

resource "aws_iam_policy" "codepipeline_places_access" {
  name   = "codepipeline-places-to-go-access"
  policy = "${data.aws_iam_policy_document.codepipeline_places_access.json}"
}

resource "aws_iam_policy" "codebuild_places_access" {
  name   = "codebuild-places-to-go-access"
  policy = "${data.aws_iam_policy_document.codebuild_places_access.json}"
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = "${aws_iam_role.places_to_go_codepipeline.id}"
  policy_arn = "${aws_iam_policy.codepipeline_places_access.arn}"
}

resource "aws_iam_role_policy_attachment" "codepipeline-artifacts" {
  role       = "${aws_iam_role.places_to_go_codepipeline.id}"
  policy_arn = "${aws_iam_policy.codepipeline_artifact_access.arn}"
}

resource "aws_iam_role_policy_attachment" "codebuld" {
  role       = "${aws_iam_role.places_to_go_codebuild.id}"
  policy_arn = "${aws_iam_policy.codebuild_places_access.arn}"
}

resource "aws_iam_role_policy_attachment" "codebuld-artifacts" {
  role       = "${aws_iam_role.places_to_go_codebuild.id}"
  policy_arn = "${aws_iam_policy.codepipeline_artifact_access.arn}"
}