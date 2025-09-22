terraform {
  required_providers {
    aws = {
      version = ">= 3.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.vpc_state_path
    region = "us-east-1"
  }
}