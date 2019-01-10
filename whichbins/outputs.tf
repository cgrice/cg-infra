output "whichbins_deploy_bucket" {
    value = "${aws_s3_bucket.whichbins_deploy_bucket.bucket}"
}

output "whichbins_lambda" {
    value = "${aws_lambda_function.whichbins_lambda.arn}"
}