# Brewery Lambda Function

This README provides a guide for deploying an AWS Lambda function that queries the Open Brewery DB API for breweries in Columbus, Ohio. The function logs the brewery name, street, and phone to CloudWatch Logs.

Prerequisites
Terraform installed on your local machine.
AWS CLI configured with appropriate permissions.
Python 3.8 installed on your local machine.

Directory Structure
project-directory/
│
├── lambda_function.py
├── main.tf
├── requirements.txt
└── README.md

Deployment Instructions
```sh
git clone <repository-url>
cd project-directory
```
Initialize Terraform
```sh
terraform init
```
Validate the Terraform Configuration
```sh
terraform validate
```
Generate and Review the Execution Plan
```sh
terraform plan
```
Deploy the Lambda Function
```sh
terraform apply
```
Verify the Deployment

Check AWS CloudWatch Logs to see the output of the Lambda function.
The function should log the name, street, and phone of each brewery in Columbus, Ohio.

Viewing Results
Go to the AWS Management Console
Navigate to CloudWatch
Select Logs in the left-hand menu
Find and select the log group named /aws/lambda/brewery-lambda
View the latest log stream to see the output of the Lambda function
The log should contain JSON entries for each brewery with the name, street, and phone, sorted by name.

Cleanup
To clean up and remove all resources created by Terraform:

```sh
terraform destroy
```
This will delete the Lambda function, IAM roles and policies, and the CloudWatch log group.

Additional Notes
Ensure that your AWS credentials have sufficient permissions to create the necessary resources.
If running into permission issues, update your AWS IAM policies accordingly.
This README should help guide you through the process of deploying the Lambda function using Terraform, including the necessary commands and configurations.
