# Brewery Lambda Project (beam_sre_kata_serverless)

This project uses Terraform to create an AWS Lambda function that queries the Open Brewery DB API for all breweries in Columbus, Ohio, and logs the `name`, `street`, and `phone` of each brewery to CloudWatch. The project includes unit tests for the Lambda function, which are executed using AWS CodeBuild before deploying the Lambda function.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS account with necessary permissions
- AWS CLI configured with appropriate credentials

## Project Structure

project//r
├── main.tf 
├── buildspec.yml 
├── lambda/ 
│ └── lambda_function.py 
└── tests/ 
└── test_lambda_function.py 

### Files

- `main.tf`: Terraform configuration file to set up the Lambda function, IAM roles, CodeBuild project, and related resources.
- `buildspec.yml`: CodeBuild specification file to install dependencies and run unit tests.
- `lambda/lambda_function.py`: Python code for the AWS Lambda function.
- `tests/test_lambda_function.py`: Unit tests for the Lambda function.

## Setup and Deployment

### Step 1: Initialize Terraform

Navigate to the project directory and run the following command to initialize Terraform:

```bash
terraform init
```
Step 2: Apply the Terraform Configuration
Apply the Terraform configuration to create the necessary AWS resources:

```bash
terraform apply
```

Confirm the apply step when prompted. This will trigger the following steps:

IAM Role Creation: Create IAM roles for the Lambda function and CodeBuild project.
S3 Bucket Creation: Create an S3 bucket to store the Lambda function code, tests, and buildspec.
CodeBuild Project: Set up an AWS CodeBuild project to run the unit tests.
Run Tests: Trigger CodeBuild to run the unit tests. The Lambda function will only be deployed if the tests pass.
Lambda Function Deployment: Deploy the Lambda function and create a CloudWatch log group.
Lambda Function
The Lambda function (lambda/lambda_function.py) queries the Open Brewery DB API and logs the name, street, and phone number of each brewery in Columbus, Ohio.

Environment Variables

CITY: The city to query (default is "Columbus").

STATE: The state to query (default is "Ohio").

Unit Testing
The unit tests are defined in tests/test_lambda_function.py and use the pytest framework. The tests mock the API response and validate the Lambda function's output.

Running Tests Locally
To run the tests locally, you can use the following commands:

Install dependencies:
```bash
pip install pytest requests
```
```bash
pytest tests/
```
Logging
The Lambda function logs its output to CloudWatch Logs. You can view the logs in the AWS Management Console under CloudWatch Logs.

Cleanup
To clean up the resources created by this project, run the following command:
```bash
terraform destroy
```
Notes
Make sure to replace placeholder values (like bucket names) with unique values as needed.
Ensure you have the necessary permissions to create and manage the AWS resources specified in this project.





