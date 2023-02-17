#!/bin/bash
#Author: Nicole Takam
#Creation Date: October 9, 2022
#Description: Creating a VPC with cidr block 10.0.0.0/16 and 50% subnets(public and private)

#Create a vpc
aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=MyVpc-coditech}]'

# Creating subnets 50% - use visual subnet calculator - 10.0.0.0/17 & 10.0.128.0/17 - subnetting and route table helps define who has access to the i
aws ec2 create-subnet \
--vpc-id vpc-0db58e45dc6736ba7 \
--cidr-block 10.0.0.0/17 \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=myprivate-subnet}]'

aws ec2 create-subnet \
--vpc-id vpc-0db58e45dc6736ba7 \
--cidr-block 10.0.128.0/17 \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=mypublic-subnet}]'

#Create internet gateway ( internet gateway is a public ip which allows instances to access internet)
aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-gateway}]'

#Attaching internetgateway to a VPC
aws ec2 attach-internet-gateway  --internet-gateway-id igw-042480cf318312114  --vpc-id vpc-0db58e45dc6736ba7
#Allocate elastic ip address for the NAT gateway
aws ec2 allocate-address --domain vpc

#create NAT gateway
aws ec2 create-nat-gateway  --subnet-id subnet-0fe3f4cd561232aa9 --allocation-id eipalloc-00a1f5769cb3d7e04

#create a routetable
aws ec2 create-route-table --vpc-id vpc-0db58e45dc6736ba7 --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=myprivatert}]'
aws ec2 create-route-table --vpc-id vpc-0db58e45dc6736ba7 --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=mypublicrt}]'
#create a route through the internet gateway( no need to tag)
aws ec2 create-route --route-table-id rtb-055672e67bf8258e9 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-042480cf318312114
#create a route through the NAT
aws ec2 create-route --route-table-id rtb-01c8230f369028c85  --destination-cidr-block 0.0.0.0/0 --gateway-id nat-0279e432730464ddf

#Associate Private RT with private subnet
aws ec2 associate-route-table --route-table-id  rtb-01c8230f369028c85 --subnet-id subnet-0959ec19b6fdefa9f
#Associate Public RT with public subnet
aws ec2 associate-route-table --route-table-id rtb-055672e67bf8258e9 --subnet-id subnet-0fe3f4cd561232aa9
#Create a security group- always created within a specific VPC
aws ec2 create-security-group --group-name securitygpnew --description "My security group" --vpc-id vpc-0db58e45dc6736ba7 --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=newsecuritygroup}]'
#Open ports on create security group ssh 22 and open to the world
#Creating a security with SSH 22 and open to the world
aws ec2 authorize-security-group-ingress --group-id sg-059b11e9e234e4017 --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-059b11e9e234e4017 --protocol tcp --port 80 --cidr 0.0.0.0/0
#Create new ec2 instance
aws ec2 run-instances \
--image-id ami-026b57f3c383c2eec \
--count 1 \
--instance-type t2.micro \
--key-name devops \
--security-group-ids sg-059b11e9e234e4017 \
--subnet-id subnet-0fe3f4cd561232aa9 \
--associate-public-ip-address \
--tag-specifications \
'ResourceType=instance,Tags=[{Key=Name,Value=web2}]'
