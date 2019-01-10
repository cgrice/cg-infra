resource "aws_sqs_queue" "notifications_outbound_queue" {
  name                       = "notifications-outbound"
  visibility_timeout_seconds = 30
  max_message_size           = 2048
}

resource "aws_lambda_event_source_mapping" "trigger_lambda_from_queue" {
  event_source_arn = "${aws_sqs_queue.notifications_outbound_queue.arn}"
  function_name    = "${aws_lambda_function.notifications_lambda.arn}"
}