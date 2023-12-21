variable "Mainvpc" {
    default = "Mainvpc"
    description = "The VPC name"
}
variable "VPCName" {
    default = "Mainvpc"
    description = "The VPC name"
}

variable "Mainvpccidr" {
    default = "10.0.0.0/16"
    description = "The CIDR block for the custom VPC"
}

variable "PublicSubnet1_CIDR" {
    default = "10.0.1.0/24"
    description = "CIDR block for Public Subnet 1"
}

variable "PublicSubnet2_CIDR" {
    default = "10.0.2.0/24"
    description = "CIDR block for Public Subnet 2"
}


variable "PrivateSubnet_CIDR" {
    default = "10.0.11.0/24"
    description = "CIDR block for Private Subnet 1"
}


variable "ApplicationLoadBalancer" {
    default = "MainVPCALB"
    description = "Application load balancer"
}


variable "igw" {
    default = "MainVPCInternetGateway"
    description = "The Internet Gateway for the VPC"
}

variable "nat_gw" {
    default = "MainVPCNATGateway"
    description = "NAT Gateway for Private Subnet"
}

variable "eip" {
    default = "MainEIP"
    description = "Elastic IP for NAT Gateway"
}

variable "nat_gw2" {
    default = "MainVPCNATGateway2"
    description = "NAT Gateway for Private Subnet 2"
}

variable "eip2" {
    default = "MainEIP2"
    description = "Elastic IP for NAT Gateway 2"
}


variable "instancetype" {
    default = "t3.micro"
    description = "Instance type for the application server"
}

variable "region" {
    default = "us-east-1"
    description = "the region to provision resources in"
}