# tf-aws-vpc-3-tier
This Terraform code to create Three-Tier Architecture an Amazon Web Services (AWS) Virtual Private Cloud (VPC)  .

## Introduction to Three-Tier Architecture
A three-tier architecture is a software architecture pattern where the application is broken down into three logical tiers: the presentation layer, the business logic layer and the data storage layer. This architecture is used in a client-server application such as a web application that has the frontend, the backend and the database. Each of these layers or tiers does a specific task and can be managed independently of each other. This a shift from the monolithic way of building an application where the frontend, the backend and the database are both sitting in one place.

## Usage

This TF code creates a VPC alongside a variety of related resources, including:

- Public, Application and Database subnets
- Public, Application and Database route tables
- Public, Application and Database NACL tables
- Elastic IPs
- NAT Gateways
- Internet Gateway