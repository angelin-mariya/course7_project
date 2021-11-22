provider "aws" {
    region = "${var.AWS_REGION}"
}
#S3 backend to store tfstate file
terraform {
  backend "s3" {
    bucket = "terraformtftorgae"
    path = store/terraform.tfstate
    region = "us-east-1"
  }

}