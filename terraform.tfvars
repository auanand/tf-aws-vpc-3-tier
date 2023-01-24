region = "us-east-1"
vpc_cidr_block = "20.0.0.0/16"
customer_name = "lup"
environment = "uat"
tags = {
    owner = "DevOps Team"
    Project = "WebApp"
}
public_subnet_cidr_blocks = ["20.0.0.0/24", "20.0.1.0/24"]
application_subnet_cidr_blocks = ["20.0.2.0/24", "20.0.3.0/24"]
database_subnet_cidr_blocks = ["20.0.4.0/24", "20.0.5.0/24"]