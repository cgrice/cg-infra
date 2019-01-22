data "terraform_remote_state" "notifications" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "notifications.tfstate"
    region   = "${var.region}"
  }
}

resource "aws_iam_role" "school_run_lambda_role" {
  name = "school-run-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "school_run_lambda_cloudwatch" {
    name = "school-run-cloudwatch-access"
    role = "${aws_iam_role.school_run_lambda_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:eu-west-1:${var.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:eu-west-1:${var.account_id}:log-group:/aws/lambda/${aws_lambda_function.school_run_lambda.function_name}:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "school_run_lambda_read_queue" {
    name = "school-run-sqs-access"
    role = "${aws_iam_role.school_run_lambda_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage",
                "sqs:GetQueueUrl"
            ],
            "Resource": "${data.terraform_remote_state.notifications.notifications_queue}"
        }
    ]
}
EOF
}