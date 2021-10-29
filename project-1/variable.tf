variable "aws_credentials_file_path" {
  default = "~/.aws/credentials"
}
variable "aws_profile_name" {}
variable "region" {}
variable "public_key_path" {}
variable "ssl_certificate_arn" {}
variable "rds_password" {}
variable "rds_username" {}
variable "rds_database_name" {}
variable "rds_instance_class" {
  default = "db.t2.micro"
}
variable "lb_name" {}
variable "target_group_name" {}
variable "key_name" {}
variable "launch_template_name" {}
variable "ami_name" {}
variable "lt_instance_type" {
  default = "t2.micro"
}
variable "elb_sg_name" {}
variable "ec2_sg_name" {}
variable "rds_sg_name" {}
variable "db_subnet_group_name" {}
variable "vpc_name" {}
variable "igw_name" {}
variable "route_table_name" {}
variable "ec2_instance_type" {
  default = "t2.micro"
}
variable "server_name" {}
variable "project_name" {}
variable "cpu_policy_name" {}
variable "domain_name" {}
variable "subdomaine_name" {}
variable "autoscaling_name" {}
variable "public_subnet_name" {}
variable "private_subnet_name" {}