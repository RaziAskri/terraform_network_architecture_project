Terraform AWS Infrastructure Setup
This project uses Terraform to automate the creation of AWS infrastructure. It sets up resources like VPC, subnets, Internet Gateway, NAT Gateway, Security Groups, and EC2 instances (both public and private) with associated key pairs for SSH access.

Table of Contents
Prerequisites

Setup

Usage

Security

Resources

License

Prerequisites
Before you start, ensure you have the following:

Terraform: Version 0.14 or later installed on your local machine. You can install it from the official site: Terraform Downloads.

AWS CLI: The AWS CLI should be configured on your machine with the correct credentials. You can configure the AWS CLI with the following command:

bash
Copier
aws configure
This will prompt you to enter your AWS Access Key ID, AWS Secret Access Key, Region, and Output format.

SSH client: A tool to connect to your EC2 instance (e.g., OpenSSH or PuTTY for Windows users).

Setup
Clone the Repository
Clone this project to your local machine:

bash
Copier
git clone https://github.com/your-username/aws-terraform-project.git
cd aws-terraform-project
Configure AWS Credentials
Make sure you have the AWS credentials set up. You can do this using the AWS CLI:

bash
Copier
aws configure
Alternatively, set environment variables for AWS credentials:

bash
Copier
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="your-region"  # e.g., "us-west-2"
If you're using EC2 metadata service for credentials, ensure that the EC2 instance has the appropriate IAM role.

Usage
Initialize Terraform
Run the following command to initialize your Terraform configuration:

bash
Copier
terraform init
Apply the Terraform Plan
To create the infrastructure, apply the Terraform configuration:

bash
Copier
terraform apply
Terraform will prompt you for confirmation. Type yes to proceed.

Outputs
After successful creation, you will see output values, including:

Public IP of EC2 instances

Security group ID

NAT Gateway ID

These values will be helpful for connecting to your EC2 instances or further configurations.

Security
Private Key
The private key to connect to EC2 instances is generated and saved on your local machine. Ensure that the private key has secure permissions:

For Linux/macOS:

bash
Copier
chmod 400 /path/to/your-key.pem
On Windows, ensure the private key file has restricted access only for your user account.

EC2 Security Group
The security group for the EC2 instances allows SSH (port 22) access from your IP address, and HTTPS (port 443) access. You can modify these rules based on your specific needs.

Resources
VPC: A custom VPC is created with both public and private subnets.

EC2 Instances: Public and private EC2 instances are created with the respective key pairs for SSH access.

NAT Gateway: A NAT Gateway is set up for internet access from private subnets.

Internet Gateway: The public subnet is connected to the internet through an Internet Gateway.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Example SSH Commands to Connect to EC2 Instances
After the infrastructure is deployed, you can connect to your EC2 instances using the private key you downloaded.

Connect to Public EC2 Instance:
bash
Copier
ssh -i /path/to/ec2_private_key_public_ec2.pem ec2-user@<Public-IP>
Replace <Public-IP> with the actual public IP of your EC2 instance.

Connect to Private EC2 Instance:
If you are connecting to the private EC2 instance, make sure you have proper access (e.g., using a bastion host or VPN, if applicable).
