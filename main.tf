provider "aws" {
  region = "us-east-2"
}

locals {
  common_tags = {
    Owner = "Swilson"
  }
  lambda_logging_policy_name = "lambda-logging-policy-${replace(formatdate("YYYYMMDDhhmmss", timestamp()), ":", "-")}"
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
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# Create Lambda function
resource "aws_lambda_function" "brewery_lambda" {
  filename         = "lambda_function.py"
  function_name    = "brewery-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 60
  source_code_hash = filebase64sha256("lambda_function.py")
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

# Create API Gateway
resource "aws_api_gateway_rest_api" "brewery_api" {
  name        = "brewery-api"
  description = "API to query breweries in Columbus, Ohio"
  tags        = local.common_tags
}

resource "aws_api_gateway_resource" "brewery_resource" {
  rest_api_id = aws_api_gateway_rest_api.brewery_api.id
  parent_id   = aws_api_gateway_rest_api.brewery_api.root_resource_id
  path_part   = "breweries"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.brewery_api.id
  resource_id   = aws_api_gateway_resource.brewery_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.brewery_api.id
  resource_id             = aws_api_gateway_resource.brewery_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.brewery_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.brewery_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.brewery_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.brewery_api.id
  stage_name  = "prod"
}

output "api_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
