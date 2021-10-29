# Get ubuntu 20.04 ami id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# Modify the script
data "template_file" "init" {
  template = file("bootscript.sh")

  vars = {
    localhost          = aws_db_instance.rds.endpoint
    database_name_here = var.rds_database_name
    username_here      = var.rds_username
    password_here      = var.rds_password
  }
  depends_on = [
    aws_db_instance.rds
  ]
}