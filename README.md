# Terraform AWS Infrastructure Setup

This project uses Terraform to automate the creation of AWS infrastructure. It sets up resources like **VPC**, **subnets**, **Internet Gateway**, **NAT Gateway**, **Security Groups**, and **EC2 instances** (both public and private) with associated **key pairs** for SSH access.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Security](#security)
5. [Resources](#resources)
6. [License](#license)

## Prerequisites

Before you start, ensure you have the following:

- **Terraform**: Version 0.14 or later installed on your local machine. You can install it from the official site: [Terraform Downloads](https://www.terraform.io/downloads.html).
- **AWS CLI**: The AWS CLI should be configured on your machine with the correct credentials. You can configure the AWS CLI with the following command:
  
  ```bash
  aws configure
SSH client: A tool to connect to your EC2 instance (e.g., OpenSSH or PuTTY for Windows users).

## Setup
Clone the Repository:
Clone this repository to your local machine:

bash
Copier
git clone https://github.com/your-username/terraform-aws-infrastructure.git
Install Terraform:
If you don't have Terraform installed, follow the installation guide at Terraform Downloads.

Configure AWS CLI:
Ensure you have the AWS CLI installed and configured with your AWS credentials. If not, use the command below to configure it:

bash
Copier
aws configure
Initialize Terraform:
In the project directory, initialize Terraform:

bash
Copier
terraform init
## Usage
To create the infrastructure, follow these steps:

Review the Configuration Files:
Review the main.tf file and other configuration files to ensure that the values match your desired configuration (e.g., region, VPC settings, etc.).

Apply the Configuration:
To create the infrastructure, run:

bash
Copier
terraform apply
Terraform will prompt you to confirm that you want to create the resources. Type yes to proceed.

Monitor Infrastructure Creation:
Terraform will display the progress of creating resources in your AWS account. Once the process is complete, you should see the created resources in your AWS Console.

## Security
This Terraform configuration automatically creates EC2 instances with associated key pairs for SSH access. Make sure to keep the private keys secure:

When downloading the private key, never share it or expose it publicly.

Ensure that the key has restricted permissions (chmod 400 on UNIX-based systems).

SSH Access
For public EC2 instances, you can connect using the associated SSH private key:

bash
Copier
ssh -i path_to_your_private_key.pem ec2-user@<your-public-ec2-public-ip>
For private EC2 instances, access can only be made through the public EC2 instance (via SSH tunneling or bastion host).

## Resources
This project creates the following AWS resources:

VPC

Subnets (Public & Private)

Internet Gateway

NAT Gateway

Route Tables

Security Groups

EC2 Instances (Public & Private)

Elastic IP

For more information about these resources, visit the AWS Documentation.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

perl
Copier

### How to Use This Markdown Code:
1. Copy the entire code above.
2. Create or open the `README.md` file in your project directory.
3. Paste the content into your `README.md` file.
4. Save the file.

Once saved, you can push the changes to your GitHub repository by running:

```bash
git add README.md
git commit -m "Added README file"
git push origin main  # or `git push origin master` depending on your default branch
