output "blog_api_deploy_bucket" {
    value = "${module.cg_api_lambda.deploy_bucket}"
}

output "blog_api_lambda" {
    value = "${module.cg_api_lambda.lambda_arn}"
}

output "blog_api_lambda_name" {
    value = "${module.cg_api_lambda.function_name}"
}

output "blog_api_lambda_invoke" {
    value = "${module.cg_api_lambda.invoke_arn}"
}