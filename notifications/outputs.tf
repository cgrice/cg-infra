output "notifications_deploy_bucket" {
    value = "${aws_s3_bucket.notifications_deploy_bucket.bucket}"
}

output "notifications_lambda" {
    value = "${aws_lambda_function.notifications_lambda.arn}"
}

output "notifications_queue" {
    value = "${aws_sqs_queue.notifications_outbound_queue.arn}"
}