# Brewery Lambda Function

This project contains Terraform configuration for deploying an AWS Lambda function that queries the Open Brewery DB API for breweries in Columbus, Ohio. The Lambda function logs the results to CloudWatch and returns a JSON list of breweries sorted by name.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Python 3.8 installed

## Setup

1. **Clone the repository:**

    ```sh
    git clone <repository_url>
    cd <repository_name>
    ```

2. **Create a Python virtual environment and install dependencies:**

    ```sh
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

3. **Run unit tests:**

    ```sh
    python -m unittest discover -s tests
    ```

4. **Initialize and apply Terraform configuration:**

    ```sh
    terraform init
    terraform apply
    ```

    Follow the prompts to approve the plan and apply the configuration.

## Resources Created

- IAM Role and Policies for the Lambda function
- S3 Bucket to store Lambda function code
- Lambda function to query the Open Brewery DB API
- CloudWatch Log Group for logging

## Lambda Function

The Lambda function queries the Open Brewery DB API for breweries in Columbus, Ohio, logs the results to CloudWatch, and returns a JSON list of breweries sorted by name.

## Testing

Unit tests are provided in the `tests` directory. You can run the tests with the following command:

```sh
python -m unittest discover -s tests
