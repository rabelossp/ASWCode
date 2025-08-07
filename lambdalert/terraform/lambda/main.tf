resource "aws_iam_role" "lambda_shutdown_role" {
  name = "lambda_shutdown_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_shutdown_policy" {
  name = "lambda_shutdown_policy"
  role = aws_iam_role.lambda_shutdown_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "lambda:DeleteFunction",
          "budgets:ViewBudget"
        ],
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/shutdown_resources.py"
  output_path = "${path.module}/shutdown_resources.zip"
}

resource "aws_lambda_function" "shutdown_resources" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "shutdown_resources"
  role             = aws_iam_role.lambda_shutdown_role.arn
  handler          = "shutdown_resources.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 30
}

output "lambda_function_name" {
  value = aws_lambda_function.shutdown_resources.function_name
}
