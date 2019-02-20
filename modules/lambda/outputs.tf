output "iam_role" {
    value = "${aws_iam_role.lambda_role.arn}"
}

output "lambda_arn" {
    value = "${aws_lambda_function.lambda.arn}"
}

output "invoke_arn" {
    value = "${aws_lambda_function.lambda.invoke_arn}"
}

output "function_name" {
    value = "${aws_lambda_function.lambda.function_name}"
}

output "deploy_bucket" {
    value = "${aws_s3_bucket.deploy_bucket.bucket}"
}