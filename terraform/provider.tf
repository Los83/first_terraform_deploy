provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket  = "web-app-s3-bucket-eieio"
    key     = "web-app/terraform-backend"
    encrypt = true
    region  = "us-east-1"
  }
}
