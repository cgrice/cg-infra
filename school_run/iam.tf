data "terraform_remote_state" "notifications" {
  backend = "s3"

  config {
    bucket   = "cg-infra-tfstate"
    key      = "notifications.tfstate"
    region   = "${var.region}"
  }
}

resource "aws_iam_role_policy" "school_run_lambda_read_queue" {
    name = "school-run-sqs-access"
    role = "${module.school_run_lambda.iam_role}"
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