resource "aws_iam_role" "notifications_lambda_role" {
  name = "notifications-lambda"

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

resource "aws_iam_role_policy" "notifications_lambda_cloudwatch" {
    name = "notifications-cloudwatch-access"
    role = "${aws_iam_role.notifications_lambda_role.id}"
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
                "arn:aws:logs:eu-west-1:${var.account_id}:log-group:/aws/lambda/${aws_lambda_function.notifications_lambda.function_name}:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "notifications_lambda_read_config" {
    name = "notifications-s3-access"
    role = "${aws_iam_role.notifications_lambda_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.notifications_config_bucket.bucket}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "notifications_lambda_read_queue" {
    name = "notifications-sqs-access"
    role = "${aws_iam_role.notifications_lambda_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sqs:ReceiveMessage"
            ],
            "Resource": "${aws_sqs_queue.notifications_outbound_queue.arn}"
        }
    ]
}
EOF
}