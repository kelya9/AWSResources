# AWSResources: BASH script for resource deployment

Description:

The aim of this demo project is to provide a proper understanding of some AWS resources. A VPC with a specific CIDR Block 10.0.0.0/16 and two subnets (private, public) were created. 
These subnets contain 50% IP address within CIDR block of the created VPC.
An internet gateway is created and attached to the VPC and route tables were created and associated to each subnet for internet connection for the EC2 instance in this subnets.

Pre-requisites
AWS CLI should be installed
IAM user with programmatic access configured
