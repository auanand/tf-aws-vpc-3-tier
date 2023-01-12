variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}

variable "vpc_cidr_block" {
    default     = "10.0.0.0/16"
    type        = string
    description = "CIDR block for the VPC"
}

variable "customer_name" {
    type        = string
    description = "Customer Name"
}

variable "environment" {
    type        = string
    description = "project Name"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}

variable "public_subnet_cidr_blocks" {
  default     = ["20.0.0.0/24", "20.0.1.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "application_subnet_cidr_blocks" {
  default     = ["20.0.2.0/24", "20.0.3.0/24"]
  type        = list
  description = "List of application subnet CIDR blocks"
}

variable "database_subnet_cidr_blocks" {
  default     = ["20.0.4.0/24", "20.0.5.0/24"]
  type        = list
  description = "List of database subnet CIDR blocks"
}