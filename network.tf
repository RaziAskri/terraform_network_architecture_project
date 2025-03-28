#provider
provider "aws" {
  #user aws infos and default region (dublin/ireland) 
  #are already assigned in the aws cli
}

###############
######vpc######
###############
resource "aws_vpc" "terraform_razi_vpc" {
  cidr_block = "10.0.0.0/16"
}

###############
#public subnet#
###############
resource "aws_subnet" "terraform_razi_public_subnet" {
  vpc_id     = aws_vpc.terraform_razi_vpc.id
  availability_zone       = "eu-west-1b"    # Specify Availability Zone B
  cidr_block = "50.0.1.0/24"

  tags = {
    Name = "public subnet"
  }
}

################
#private subnet#
################
resource "aws_subnet" "terraform_razi_private_subnet" {
  vpc_id     = aws_vpc.terraform_razi_vpc.id
  cidr_block = "50.0.2.0/24"
  availability_zone       = "eu-west-1b"    # Specify Availability Zone B

  tags = {
    Name = "private subnet"
  }
}

##################
#internet gateway#
##################
resource "aws_internet_gateway" "terraform_razi_internet_gateway" {
  vpc_id = aws_vpc.terraform_razi_vpc.id

   tags = {
    Name = "internet gateway"
  }
}

##############
##elastic ip##
##############
resource "aws_eip" "terraform_razi_elastic_ip" {
  domain   = "vpc"
}

#############
#Nat gateway#
#############
resource "aws_nat_gateway" "terraform_razi_Nat_Gateway" {
  allocation_id = aws_eip.terraform_razi_elastic_ip.id
  subnet_id     = aws_subnet.terraform_razi_public_subnet.id

  tags = {
    Name = "NAT gateway"
  }
}

#############################################
#public route table for the internet gateway#
#############################################
resource "aws_route_table" "terraform_razi_route_table_for_internet_gw" {
  vpc_id = aws_vpc.terraform_razi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_razi_internet_gateway.id
  }

  tags = {
    Name = "route table for internet gw"
  }
}

#######################################################################################
#this is the association resource that associates the route table to the public subnet#
#######################################################################################
resource "aws_route_table_association" "terraform_route_table_association_to_internet_gw" {
  subnet_id      = aws_subnet.terraform_razi_public_subnet.id
  route_table_id = aws_route_table.terraform_razi_route_table_for_internet_gw.id
}


#############################################
#public route table for the NAT gateway#
#############################################
resource "aws_route_table" "terraform_razi_route_table_for_NAT_gateway" {
  vpc_id = aws_vpc.terraform_razi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_razi_Nat_Gateway.id  # NAT Gateway ID
  }

  tags = {
    Name = "route table for NAT gw"
  }
}

#######################################################################################
#this is the association resource that associates the route table to the private subnet#
#######################################################################################
resource "aws_route_table_association" "terraform_route_table_association_to_NAT_gw" {
  subnet_id      = aws_subnet.terraform_razi_private_subnet.id
  route_table_id = aws_route_table.terraform_razi_route_table_for_NAT_gateway.id
}
