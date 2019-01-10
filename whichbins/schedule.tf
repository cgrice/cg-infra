resource "aws_cloudwatch_event_rule" "trigger_whichbins_check" {
  name        = "trigger-whichbins-check"
  description = "Run the whichbins lambda every day at 5:30PM"
  schedule_expression = "cron(30 17 ? * * *)"
}

resource "aws_cloudwatch_event_target" "whichbins_lambda" {
  rule      = "${aws_cloudwatch_event_rule.trigger_whichbins_check.name}"
  arn       = "${aws_lambda_function.whichbins_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_whichbins" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.whichbins_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.trigger_whichbins_check.arn}"
}