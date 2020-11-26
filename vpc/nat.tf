module "nat" {
  source                 = "git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git"
  name                   = "nat-instance"
  instance_count         = 1

  ami                    = "ami-0ea87e2bfa81ca08a"
  instance_type          = "t2.nano"
  monitoring             = false
  key_name = "cg-infra"
  vpc_security_group_ids = ["${module.default_sg.this_security_group_id}"]
  subnet_ids             = ["${module.vpc.public_subnets}"]
  associate_public_ip_address = true
  source_dest_check = false

}

module "default_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "prod-vpc"
  description = "Default SG for prod VPC"
  vpc_id      = "${module.vpc.vpc_id}"

   
}