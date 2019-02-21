output "school_run_deploy_bucket" {
    value = "${module.school_run_lambda.deploy_bucket}"
}

output "school_run_lambda" {
    value = "${module.school_run_lambda.lambda_arn}"
}