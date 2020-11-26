resource "aws_db_subnet_group" "places_db" {
  name       = "places_db_subnets"
  subnet_ids = ["${data.terraform_remote_state.vpc.private_subnets}"]
}

resource "aws_rds_cluster" "places" {
  cluster_identifier      = "places-db"
  engine                  = "aurora"
  engine_version          = "5.6.10a"
  engine_mode             = "serverless"
  availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name           = "places_to_go"
  master_username         = "places"
  master_password         = "${var.db_password}"
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  final_snapshot_identifier = "places-db-final"
  db_subnet_group_name = "${aws_db_subnet_group.places_db.name}"
}