# Restaurant Query App

## Overview
This application allows users to query a database for currently open restaurants based on specific parameters. It includes a health check endpoint and an audit log access feature.

## Architecture
- **VPC Configuration**: 
  - 2 Public subnets across 2 Availability Zones (AZs)
  - 1 Private subnet
  - Elastic IPs (EIPs)
  - NAT Gateways (Nat GWs)
  - Internet Gateways (IGWs)
- **EC2 Instance**: Amazon EC2 instance with an Application Load Balancer (ALB).
- **DynamoDB**: 
  - Tables: `restaurants` & `audit`
- **S3 Bucket**: Storage for application data.
- **Parameter Store**: For secret management.

## Application Usage
- **/search**: Query the restaurants database for currently open restaurants.
  - Parameters:
    - `style`: Cuisine style (e.g., Thai, British, Mediterranean, Brazilian).
    - `isVegetarian`: Boolean value (true/false).
- **/health**: Health check endpoint.
- **/audit**: Access to the audit log.
  - Parameters:
    - `maxLastRecords` (optional): Number of last records to present (default is 5).
  - Authentication: Requires a passcode (obtain from Terraform output). Username can be arbitrary.

## Infrastructure Deployment
1. Navigate to the Terraform directory:
cd terraform
2. Initialize Terraform:
terraform init
3. Plan the deployment:
terraform plan --var-file=main.tfvars
4. Apply the configuration:
terraform apply --var-file=main.tfvars

## Outputs
- **ALB Address**: URL of the application.
- **Audit Endpoint Password**: Password for audit log access.

## Components
- `main.py`: The main application script.
- `db_load.py`: Helper script for initial database population.
- `restlist.json`: JSON file containing the list of all restaurants.
- `ec2init.sh`: User data bootstrap script for the EC2 instance.

## CI/CD
- **Database Update**: Any commit to `master` that modifies `restlist.json` will trigger a database update flow.
- **Application Update**: Any commit to `master` that modifies `main.py`, `db_load.py`, or `requirements.txt` will trigger an update to the application on the EC2 instance.
