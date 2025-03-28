#provider
provider "aws" {
  #user infos and default region are already assigned in the aws cli
}

###############
######vpc######
###############

#the existing vpc id hardcoded
variable "vpc_id" {
  default = "vpc-07e2e0f58f11c50d6"
}

#assign the vpc var to data block
data "aws_vpc" "terraform_razi_vpc" {
  id = var.vpc_id
}

###############
#public subnet#
###############
resource "aws_subnet" "terraform_razi_public_subnet" {
  vpc_id     = data.aws_vpc.terraform_razi_vpc.id
  availability_zone       = "eu-west-1b"    # Specify Availability Zone B
  #cidr_block = cidrsubnet(data.aws_vpc.terraform_razi_vpc.cidr_block, 8, 1)
  cidr_block = "50.30.26.0/24"

  tags = {
    Name = "terraform_razi_public_subnet"
  }
}

################
#private subnet#
################
resource "aws_subnet" "terraform_razi_private_subnet" {
  vpc_id     = data.aws_vpc.terraform_razi_vpc.id
  availability_zone       = "eu-west-1b"    # Specify Availability Zone B
  #cidr_block = cidrsubnet(data.aws_vpc.terraform_razi_vpc.cidr_block, 8, 2)
  cidr_block = "50.30.27.0/24"

  tags = {
    Name = "terraform_razi_private_subnet"
  }
}

##################
#internet gateway#
##################

data "aws_internet_gateway" "terraform_razi_existing_internet_gateway" {
  filter {
    name   = "tag:Name"
    values = ["km-abs-gateway-tp-aws"]  # the Name of the existing internet gateway
  }
}

##############
##elastic ip##
##############

#fetch the existing eip using data blocks
data "aws_eip" "terraform_razi_existing_eip" {
  id = "eipalloc-0dab1c043a0c70f9d" #the existing eip allocation id
}

#############
#Nat gateway#
#############
resource "aws_nat_gateway" "terraform_razi_Nat_Gateway" {
  allocation_id = data.aws_eip.terraform_razi_existing_eip.id
  subnet_id     = aws_subnet.terraform_razi_public_subnet.id

  tags = {
    Name = "terraform_razi_Nat_Gateway"
  }
}

#############################################
#public route table for the internet gateway#
#############################################
resource "aws_route_table" "terraform_razi_route_table_for_internet_gw" {
  vpc_id = data.aws_vpc.terraform_razi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.terraform_razi_existing_internet_gateway.id
  }

  tags = {
    Name = "terraform_razi_route_table_for_internet_gw"
  }
}

#######################################################################################
#this is the association resource that associates the route table to the public subnet#
#######################################################################################
resource "aws_route_table_association" "terraform_route_table_association_to_internet_gw" {
  subnet_id      = aws_subnet.terraform_razi_public_subnet.id
  route_table_id = aws_route_table.terraform_razi_route_table_for_internet_gw.id
}


########################################
#public route table for the NAT gateway#
########################################
resource "aws_route_table" "terraform_razi_route_table_for_NAT_gateway" {
  vpc_id = data.aws_vpc.terraform_razi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_razi_Nat_Gateway.id  # NAT Gateway ID
  }

  tags = {
    Name = "terraform_razi_route_table_for_NAT_gateway"
  }
}

########################################################################################
#this is the association resource that associates the route table to the private subnet#
########################################################################################
resource "aws_route_table_association" "terraform_route_table_association_to_NAT_gw" {
  subnet_id      = aws_subnet.terraform_razi_private_subnet.id
  route_table_id = aws_route_table.terraform_razi_route_table_for_NAT_gateway.id
}

####################################
#public EC2 key & instance creation#
####################################

# Generate a new private key for EC2 instance
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "C:/Users/RaziASKRI/Desktop/projects/aws_instances_keys/ec2_private_key_public_ec2.pem"  # Path to save the private key
}


# Create an EC2 Key Pair using the generated private key
resource "aws_key_pair" "terraform_razi_ec2_public_pk" {
  key_name   = "ec2-public-key-pair"
  public_key = tls_private_key.pk.public_key_openssh
}


resource "aws_instance" "terraform_razi_ec2_public" {
  
  ami             = "ami-0a007a006645e86ab"  # Replace with the AMI ID you want to use (e.g., Amazon Linux 2)
  instance_type   = "t2.micro"                # Change instance type as needed
  key_name        = aws_key_pair.terraform_razi_ec2_public_pk.key_name  # Use the key pair created above
  subnet_id       = aws_subnet.terraform_razi_public_subnet.id #the subnet hosting the instance
  associate_public_ip_address = true          # Automatically assign a public IP
  security_groups = [aws_security_group.terraform_razi_ec2_sg.id]        # security group name or ID

  tags = {
    Name = "terraform_razi_ec2_public"
  }
}

#####################################
#private EC2 key & instance creation#
#####################################

# Generate a new private key for EC2 instance
resource "tls_private_key" "pk_private_ec2" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create an EC2 Key Pair using the generated private key
resource "aws_key_pair" "terraform_razi_ec2_private_pk" {
  key_name   = "ec2-private-key-pair"
  public_key = tls_private_key.pk_private_ec2.public_key_openssh
}

resource "aws_instance" "terraform_razi_ec2_private" {

  ami             = "ami-0a007a006645e86ab"  # Replace with the AMI ID you want to use (e.g., Amazon Linux 2)
  instance_type   = "t2.micro"                # Change instance type as needed
  key_name        = aws_key_pair.terraform_razi_ec2_private_pk.key_name  # Use the key pair created above
  subnet_id       = aws_subnet.terraform_razi_private_subnet.id #the subnet hosting the instance
  associate_public_ip_address = false          # don't assign a public IP
  security_groups = [aws_security_group.terraform_razi_ec2_sg.id]        # security group name or ID

  tags = {
    Name = "terraform_razi_ec2_private"
  }
}

##################################################
#security group for ec2 instances & ingress rules#
##################################################

resource "aws_security_group" "terraform_razi_ec2_sg" {
  name        = "allow_https_ssh"
  description = "Allow HTTPS and SSH access"
  vpc_id      = data.aws_vpc.terraform_razi_vpc.id

  tags = {
    Name = "terraform_razi_ec2_sg"
  }
}

# Règle pour autoriser l'accès SSH (port 22)
resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Accès SSH depuis n'importe où (à restreindre si nécessaire)
  security_group_id = aws_security_group.terraform_razi_ec2_sg.id
}

# Règle pour autoriser l'accès HTTPS (port 443)
resource "aws_security_group_rule" "allow_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Accès HTTPS depuis n'importe où (à restreindre si nécessaire)
  security_group_id = aws_security_group.terraform_razi_ec2_sg.id
}
