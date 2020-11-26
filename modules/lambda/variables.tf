variable "name" {}
variable "handler" {}
variable "runtime" {}
variable "env_vars" {
    type = "map"
    default = {}
}
variable "region" {}
variable "account_id" {}
variable "timeout" {}

variable "subnet_ids" {
    type = "list"
    default = []
}

variable "security_group_ids" {
    type = "list"
    default = []
}

