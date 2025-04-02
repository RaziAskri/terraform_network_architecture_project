# Provider block
provider "aws" {
  # user infos and default region are already assigned in the AWS CLI
}

###############
######vpc######
###############

# assign the vpc var to data block
data "aws_vpc" "terraform_razi_vpc" {
  id = "vpc-07e2e0f58f11c50d6"
}

###############
# Public subnet#
###############
resource "aws_subnet" "terraform_razi_public_subnet" {
  vpc_id            = data.aws_vpc.terraform_razi_vpc.id
  availability_zone = "eu-west-1b" # Specify Availability Zone B
  cidr_block        = "50.30.26.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_razi_public_subnet"
  }
}

################
# Private subnet#
################
resource "aws_subnet" "terraform_razi_private_subnet" {
  vpc_id            = data.aws_vpc.terraform_razi_vpc.id
  availability_zone = "eu-west-1b" # Specify Availability Zone B
  cidr_block        = "50.30.27.0/24"

  tags = {
    Name = "terraform_razi_private_subnet"
  }
}

###################
# Internet gateway#
###################
data "aws_internet_gateway" "terraform_razi_existing_internet_gateway" {
  filter {
    name   = "tag:Name"
    values = ["km-abs-gateway-tp-aws"] # the Name of the existing internet gateway
  }
}

###############
## Elastic IP##
###############
data "aws_eip" "terraform_razi_existing_eip" {
  id = "eipalloc-040ed811f144399f8" # the existing eip allocation id
}

##############
# Nat gateway#
##############
resource "aws_nat_gateway" "terraform_razi_Nat_Gateway" {
  allocation_id = data.aws_eip.terraform_razi_existing_eip.id
  subnet_id     = aws_subnet.terraform_razi_public_subnet.id

  tags = {
    Name = "terraform_razi_Nat_Gateway"
  }
}

#############################################
# Create a Route Table for the Public Subnet#
#############################################
resource "aws_route_table" "terraform_razi_public_route_table" {
  vpc_id = data.aws_vpc.terraform_razi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.terraform_razi_existing_internet_gateway.id
  }

  tags = {
    Name = "terraform_razi_public_route_table"
  }
}

##################################################
# Associate the Route Table to the Public Subnet #
##################################################
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.terraform_razi_public_subnet.id
  route_table_id = aws_route_table.terraform_razi_public_route_table.id
}


###############################################
# Create a Route Table for the private Subnet #
###############################################

#create a private route table
resource "aws_route_table" "terraform_razi_private_route_table" {
  vpc_id = data.aws_vpc.terraform_razi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_razi_Nat_Gateway.id  # NAT Gateway ID
  }

  tags = {
    Name = "terraform_razi_private_route_table"
  }
}

###################################################
# Associate the Route Table to the private Subnet #
###################################################

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.terraform_razi_private_subnet.id # Reference to the private subnet
  route_table_id = aws_route_table.terraform_razi_private_route_table.id
}

#####################################
# Public EC2 instance key & creation#
#####################################

# EC2 instance creation
resource "aws_instance" "terraform_razi_ec2_public" {
  
  ami                         = "ami-0a007a006645e86ab"                             # Replace with the AMI ID you want to use (e.g., Amazon Linux 2)
  instance_type               = "t2.micro"                                          # Change instance type as needed
  key_name                    = "terraform_razi_ec2_pk" 
  subnet_id                   = aws_subnet.terraform_razi_public_subnet.id          # The subnet hosting the instance
  associate_public_ip_address = true                                                # Automatically assign a public IP
  security_groups             = [aws_security_group.terraform_razi_ec2_sg.id]       # Security group name or ID

  tags = {
    Name = "terraform_razi_ec2_public"
  }
}


#####################################
# Private EC2 instance key & creation#
#####################################


resource "aws_instance" "terraform_razi_ec2_private" {

  ami                         = "ami-0a007a006645e86ab"                             # Replace with the AMI ID you want to use (e.g., Amazon Linux 2)
  instance_type               = "t2.micro"                                          # Change instance type as needed
  key_name                    = "terraform_razi_ec2_pk" 
  subnet_id                   = aws_subnet.terraform_razi_private_subnet.id         # The subnet hosting the instance
  associate_public_ip_address = false                                               # Don't assign a public IP
  security_groups = [aws_security_group.terraform_razi_ec2_sg.id,
  aws_security_group.terraform_razi_private_ec2_sg.id] # Security group name or ID

  tags = {
    Name = "terraform_razi_ec2_private"
  }
}

##################################################
#security group for ec2 instances & sg rules#
##################################################

resource "aws_security_group" "terraform_razi_ec2_sg" {
  name        = "sg_for_public_and_private_ec2"
  description = "Allow HTTPS and SSH access"
  vpc_id      = data.aws_vpc.terraform_razi_vpc.id

  tags = {
    Name = "terraform_razi_ec2_sg"
  }
}

# Règle pour autoriser l'accès SSH (port 22)
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Accès SSH depuis n'importe où (à restreindre si nécessaire)
  security_group_id = aws_security_group.terraform_razi_ec2_sg.id
}

# Règle pour autoriser l'accès HTTPS (port 443)
resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Accès HTTPS depuis n'importe où (à restreindre si nécessaire)
  security_group_id = aws_security_group.terraform_razi_ec2_sg.id
}

  # Outbound Rules (Allowing ICMP - ping - to anywhere)
  resource "aws_security_group_rule" "outbound_rule" {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.terraform_razi_ec2_sg.id
  }
#####################################

resource "aws_security_group" "terraform_razi_private_ec2_sg" {
  name        = "sg_for_private_ec2"
  description = "Allow SSH access from public EC2"
  vpc_id      = data.aws_vpc.terraform_razi_vpc.id

  tags = {
    Name = "terraform_razi_private_ec2_sg"
  }
}

resource "aws_security_group_rule" "allow_ssh_from_public_ec2" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.terraform_razi_private_ec2_sg.id
  source_security_group_id = aws_security_group.terraform_razi_ec2_sg.id # Allow from public EC2's SG
}
