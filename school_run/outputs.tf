output "school_run_deploy_bucket" {
    value = "${aws_s3_bucket.school_run_deploy_bucket.bucket}"
}

output "school_run_lambda" {
    value = "${aws_lambda_function.school_run_lambda.arn}"
}