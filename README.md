# Beam SRE Serverless Brewery Lambda Function

This README provides a guide for deploying an AWS Lambda function that queries the Open Brewery DB API for breweries in Columbus, Ohio. The function logs the brewery name, street, and phone to CloudWatch Logs.

Prerequisites
- Terraform installed on your local machine.
- AWS CLI configured with appropriate permissions.
- Python 3.8 installed on your local machine.

Directory Structure
project-directory/\
│\
├── lambda_function.py\
├── main.tf\
├── requirements.txt\
└── README.md\


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

- Check AWS CloudWatch Logs to see the output of the Lambda function.
- The function should log the name, street, and phone of each brewery in Columbus, Ohio.

Viewing Results
- Go to the AWS Management Console
- Navigate to CloudWatch
- Select Logs in the left-hand menu
- Find and select the log group named /aws/lambda/brewery-lambda
- View the latest log stream to see the output of the Lambda function
- The log should contain JSON entries for each brewery with the name, street, and phone, sorted by name.

Cleanup
To clean up and remove all resources created by Terraform:

```sh
terraform destroy
```
This will delete the Lambda function, IAM roles and policies, and the CloudWatch log group.

Additional Notes
- Ensure that your AWS credentials have sufficient permissions to create the necessary resources.
- If running into permission issues, update your AWS IAM policies accordingly.

This README should help guide you through the process of deploying the Lambda function using Terraform, including the necessary commands and configurations.

# Description of main.tf

Provider Configuration-
Configures the AWS provider to use the us-east-2 region.

Local Variables-
Defines common tags (Owner: Swilson) to be applied to all resources.

IAM Role for Lambda-
Creates an IAM role for the Lambda function with a policy allowing Lambda to assume the role.

Attach Basic Lambda Execution Policy-
Attaches the AWS-managed policy AWSLambdaBasicExecutionRole to the IAM role, enabling CloudWatch logging.

Lambda Function-
Defines the Lambda function to query the Open Brewery DB API for breweries in Columbus, Ohio. Specifies the function name, runtime, handler, IAM role, environment variables, and the ZIP file containing the function code.

CloudWatch Log Group-
Creates a CloudWatch Log Group for storing the Lambda function logs with a retention period of 14 days.

Lambda Logging Policy-
Creates and attaches a custom IAM policy to the Lambda role, allowing it to create and write logs to CloudWatch.

Local Execution to Create ZIP File-
Uses a local-exec provisioner to create a ZIP file containing the Lambda function code directly from the local machine without manual intervention.

# Description of lambda_function.py

The lambda_function.py script contains the code for an AWS Lambda function that queries the Open Brewery DB API to retrieve information about breweries located in Columbus, Ohio. 

The function performs the following tasks: 

Environment Variables: Retrieves environment variables CITY and STATE to specify the location for the brewery search.

API Request: Constructs a URL to query the Open Brewery DB API for breweries in the specified city and state.

Data Retrieval: Sends a GET request to the API and reads the response data.

Data Processing: Parses the JSON response from the API and extracts the name, street, and phone fields for each brewery.

Sorting: Sorts the list of breweries by their name in ascending order.

Logging: Logs the processed brewery information to AWS CloudWatch in JSON format.

The function utilizes the urllib module to handle HTTP requests and responses.
