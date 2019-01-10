resource "aws_iam_role" "whichbins_lambda_role" {
  name = "whichbins-lambda"

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

resource "aws_iam_role_policy" "whichbins_lambda_cloudwatch" {
    name = "whichbins-cloudwatch-access"
    role = "${aws_iam_role.whichbins_lambda_role.id}"
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
                "arn:aws:logs:eu-west-1:${var.account_id}:log-group:/aws/lambda/${aws_lambda_function.whichbins_lambda.function_name}:*"
            ]
        }
    ]
}
EOF

}
// TODO: Add cloudwatch and SQS permissions!