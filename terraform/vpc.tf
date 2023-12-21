#### VPC and SUBNETS ####
resource "aws_vpc" "Mainvpc" {
    cidr_block = var.Mainvpccidr
    tags = {
        Name = var.VPCName
    }
}

resource "aws_subnet" "PublicSubnet1" {
    vpc_id = aws_vpc.Mainvpc.id
    cidr_block = var.PublicSubnet1_CIDR
    availability_zone = "us-east-1a"
    tags = {
        Name = "PublicSubnet1"
    }
}

resource "aws_subnet" "PublicSubnet2" {
    vpc_id = aws_vpc.Mainvpc.id
    cidr_block = var.PublicSubnet2_CIDR
    availability_zone = "us-east-1b"
    tags = {
        Name = "PublicSubnet2"
    }
}


resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.Mainvpc.id
    cidr_block = var.PrivateSubnet_CIDR
    availability_zone = "us-east-1a"
    tags = {
        Name = "PrivateSubnet"
    }
}


#### GATEWAYS ####
resource "aws_internet_gateway" "MainInternetGateway" {
    vpc_id = aws_vpc.Mainvpc.id
    tags = {
        Name = var.igw
    }
}

resource "aws_nat_gateway" "MainNATGateway" {
    allocation_id = aws_eip.MainEIP.id
    depends_on = [aws_internet_gateway.MainInternetGateway, aws_eip.MainEIP]
    subnet_id = aws_subnet.PublicSubnet1.id
    tags = {
        Name = var.nat_gw
    }
}

resource "aws_nat_gateway" "MainNATGateway2" {
    allocation_id = aws_eip.MainEIP2.id
    depends_on = [aws_internet_gateway.MainInternetGateway, aws_eip.MainEIP2]
    subnet_id = aws_subnet.PublicSubnet2.id
    tags = {
        Name = var.nat_gw2
    }
}



#### EIP ####

resource "aws_eip" "MainEIP" {
    domain = "vpc"
    tags = {
        Name = var.eip
    }
} 

resource "aws_eip" "MainEIP2" {
    domain = "vpc"
    tags = {
        Name = var.eip2
    }
} 

#### ROUTES ####

resource "aws_route_table" "PublicRouteTable" {
    vpc_id = aws_vpc.Mainvpc.id
    route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.MainInternetGateway.id
        }
    tags = {
        Name = "PublicRouteTable"
    }
}

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.PublicSubnet1.id
    route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "b" {
    subnet_id = aws_subnet.PublicSubnet2.id
    route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table" "PrivateRouteTable" {
    vpc_id = aws_vpc.Mainvpc.id
    route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_nat_gateway.MainNATGateway.id
        }
    tags = {
        Name = "PrivateRouteTable"
    }
}

resource "aws_route_table_association" "c" {
    subnet_id = aws_subnet.PrivateSubnet.id
    route_table_id = aws_route_table.PrivateRouteTable.id
}


#### SG ####

resource "aws_security_group" "MainPublicSG" {
    name = "Main-PUB-ALB-SG"
    description = "Allows web access"
    vpc_id = aws_vpc.Mainvpc.id
    
    ingress {
            description = "Allow traffic from everywhere"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Main-PUB-ALB-SG"
    }
}

resource "aws_security_group" "MainEC2SG" {
    name = "Main-EC2-SG"
    description = "Allows ALB to access the EC2 instances"
    vpc_id = aws_vpc.Mainvpc.id
    
    ingress {
            description = "Allow port 80 traffic from ALB"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            security_groups = [aws_security_group.MainPublicSG.id]
    }
    egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Main-EC2-SG"
    }
}
