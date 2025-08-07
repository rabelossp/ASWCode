module "shutdown_lambda" {
  source = "./lambda"
}

resource "aws_s3_bucket" "example" {
  bucket        = "exemplo-terraform-${var.environment}"
  force_destroy = true
}
