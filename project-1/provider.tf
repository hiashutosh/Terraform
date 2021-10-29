terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = var.aws_credentials_file_path
  profile                 = var.aws_profile_name
}