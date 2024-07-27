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

# Create an S3 bucket for CodeBuild
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "codebuild-bucket-${random_id.bucket_id.hex}"
  tags   = local.common_tags
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

# Upload buildspec and tests to S3
resource "aws_s3_bucket_object" "buildspec" {
  bucket = aws_s3_bucket.codebuild_bucket.bucket
  key    = "buildspec.yml"
  source = "${path.module}/buildspec.yml"
}

resource "aws_s3_bucket_object" "lambda_code" {
  bucket = aws_s3_bucket.codebuild_bucket.bucket
  key    = "lambda/lambda_function.py"
  source = "${path.module}/lambda/lambda_function.py"
}

resource "aws_s3_bucket_object" "tests" {
  bucket = aws_s3_bucket.codebuild_bucket.bucket
  key    = "tests/test_lambda_function.py"
  source = "${path.module}/tests/test_lambda_function.py"
}

# Create IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# Create CodeBuild project
resource "aws_codebuild_project" "lambda_tests" {
  name           = "lambda-tests"
  service_role   = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type            = "S3"
    location        = "${aws_s3_bucket.codebuild_bucket.bucket}/buildspec.yml"
    buildspec       = "buildspec.yml"
  }
  tags = local.common_tags
}

# Trigger CodeBuild to run the tests
resource "null_resource" "trigger_codebuild" {
  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.lambda_tests.name}"
  }
  depends_on = [aws_codebuild_project.lambda_tests]
}

# Wait for CodeBuild to complete and check the build status
data "aws_codebuild_build" "latest_build" {
  project_name = aws_codebuild_project.lambda_tests.name
  depends_on   = [null_resource.trigger_codebuild]
}

resource "null_resource" "wait_for_tests" {
  provisioner "local-exec" {
    command = <<EOT
      STATUS=$(aws codebuild batch-get-builds --ids ${data.aws_codebuild_build.latest_build.id} --query 'builds[0].buildStatus' --output text)
      if [ "$STATUS" != "SUCCEEDED" ]; then
        echo "Tests failed, aborting deployment."
        exit 1
      fi
    EOT
  }
  depends_on = [data.aws_codebuild_build.latest_build]
}

# Deploy Lambda function only if tests pass
resource "aws_lambda_function" "brewery_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "brewery-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = 60
  tags             = local.common_tags

  environment {
    variables = {
      CITY  = "Columbus"
      STATE = "Ohio"
    }
  }
  depends_on = [null_resource.wait_for_tests]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.brewery_lambda.function_name}"
  retention_in_days = 14
  tags              = local.common_tags
  depends_on        = [aws_lambda_function.brewery_lambda]
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
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}
