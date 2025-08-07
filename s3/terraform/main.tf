provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "example" {
  bucket = "exemplo-terraform-${var.environment}"
  force_destroy = true
}
