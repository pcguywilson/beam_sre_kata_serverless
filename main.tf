provider "aws" {
  region = "us-east-2"
}

locals {
  common_tags = {
    Owner = "Swilson"
  }
}

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

resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "lambda-code-bucket-${random_id.bucket_id.hex}"
  tags   = local.common_tags
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

# Create a zip file for the lambda function
resource "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = file("${path.module}/lambda_function.py")
    filename = "lambda_function.py"
  }

  source {
    content  = filebase64("${path.module}/requirements.txt")
    filename = "requirements.txt"
  }
}

resource "null_resource" "pip_install" {
  provisioner "local-exec" {
    command = <<-EOF
      mkdir -p ${path.module}/python
      pip install -r ${path.module}/requirements.txt -t ${path.module}/python
      cp ${path.module}/lambda_function.py ${path.module}/python/
      cd ${path.module}/python && zip -r ${path.module}/lambda_function.zip .
    EOF
  }
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code_bucket.bucket
  key    = "lambda_function.zip"
  source = "${path.module}/lambda_function.zip"
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

  depends_on = [aws_s3_object.lambda_code]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.brewery_lambda.function_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

locals {
  lambda_logging_policy_name = "lambda-logging-policy-${replace(formatdate("YYYYMMDDhhmmss", timestamp()), ":", "-")}"
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name   = local.lambda_logging_policy_name
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
