provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
resource "aws_vpc" "main" {
	cidr_block = "20.20.0.0/16"
        tags = {
           Name = "abhivpc"
        }
}
resource "aws_subnet" "public" {
	vpc_id = aws_vpc.main.id
        cidr_block = "20.20.1.0/24"
        map_public_ip_on_launch = "true"
        tags = { 
          Name = "public"
        }
}
resource "aws_subnet" "private" {
	vpc_id = aws_vpc.main.id
	cidr_block = "20.20.2.0/24"
        map_public_ip_on_launch = "true"
        tags = {
          Name = "private"
        }
}
resource "aws_internet_gateway" "gw" {
       vpc_id = aws_vpc.main.id
       tags = {
         Name = "abhigw"
       }
}
resource "aws_route_table" "route" {
      vpc_id = aws_vpc.main.id 
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
      }
      tags = {
        Name = "publicroute"
      }
}
resource "aws_route_table_association" "a1" {
      subnet_id = aws_subnet.public.id
      route_table_id = aws_route_table.route.id
} 
resource "aws_eip" "eip" {
      vpc = "true"
}
resource "aws_nat_gateway" "natgw" {
     allocation_id = aws_eip.eip.id
     subnet_id     = aws_subnet.public.id

     tags = {
       Name = "abhinat"
     }
}
resource "aws_route_table" "privateroute" {
      vpc_id = aws_vpc.main.id
      route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
      }
      tags = {
        Name = "privateroute"
      }
}
resource "aws_route_table_association" "a2" {
      subnet_id = aws_subnet.private.id
      route_table_id = aws_route_table.privateroute.id
}
