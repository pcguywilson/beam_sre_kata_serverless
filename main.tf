provider "aws" {
  region = "us-east-2"
}

locals {
  common_tags = {
    Owner = "Swilson"
  }
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "lambda-code-bucket-${random_id.bucket_id.hex}"
  tags   = local.common_tags
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code_bucket.bucket
  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path
}

resource "aws_lambda_function" "brewery_lambda" {
  s3_bucket        = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key           = aws_s3_object.lambda_code.key
  function_name    = "brewery-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 60
  tags             = local.common_tags

  environment {
    variables = {
      CITY  = "Columbus"
      STATE = "Ohio"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.brewery_lambda.function_name}"
  retention_in_days = 14
  tags              = local.common_tags
  depends_on        = [aws_lambda_function.brewery_lambda]
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name = "lambda-logging-policy-${timestamp()}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}
