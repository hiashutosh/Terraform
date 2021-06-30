terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00399ec92321828f5 "
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-test"
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "terraform-vpc"
  cidr                 = "172.33.0.0/16"
  azs                  = ["eu-east-2a", "eu-east-2b", "eu-east-2c"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true


}
