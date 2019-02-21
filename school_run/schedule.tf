resource "aws_cloudwatch_event_rule" "trigger_school_run_check" {
  name        = "trigger-school-run-check"
  description = "Run the school-run lambda every weekday at 7:55AM"
  schedule_expression = "cron(55 7 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "school_run_lambda" {
  rule      = "${aws_cloudwatch_event_rule.trigger_school_run_check.name}"
  arn       = "${module.school_run_lambda.lambda_arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_school_run" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${module.school_run_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.trigger_school_run_check.arn}"
}