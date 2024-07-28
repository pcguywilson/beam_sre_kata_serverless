provider "aws" {
  region = "us-east-2"
}

locals {
  common_tags = {
    Owner = "Swilson"
  }
}

# IAM Role for Lambda
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

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name   = "lambda-logging-policy"
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
  tags = local.common_tags
}

# Create Lambda function
resource "aws_lambda_function" "brewery_lambda" {
  filename         = "${path.module}/lambda_function.zip"
  function_name    = "brewery-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  tags             = local.common_tags

  environment {
    variables = {
      CITY  = "Columbus"
      STATE = "Ohio"
    }
  }
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.brewery_lambda.function_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

# Create Lambda deployment package
resource "null_resource" "pip_install" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./python &&
      pip install -r requirements.txt -t ./python &&
      cp lambda_function.py ./python/ &&
      cd python && zip -r ../lambda_function.zip .
    EOT
  }
}
