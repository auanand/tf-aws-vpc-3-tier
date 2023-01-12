#Creating VPC
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(
    {
        Name = "${var.customer_name}-${var.environment}-vpc",
        Environment = var.environment
    },
    var.tags
  )
}

#Creating Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-igw",
      Environment = var.environment
    },
    var.tags
  )
}

#Creating Public Routing Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-public-rt",
      Environment = var.environment
    },
    var.tags
  )
}

#Add IGW entry in public routing table
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

#Creating Public NACL
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.default.id
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-public-nacl",
      Environment = var.environment
    },
    var.tags
  )
}

#Add ingress entry in public NACL
resource "aws_network_acl_rule" "public-ingress" {
  network_acl_id = aws_network_acl.public.id
  egress = false
  protocol   = -1
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

#Add egress entry in public NACL
resource "aws_network_acl_rule" "public-egress" {
  network_acl_id = aws_network_acl.public.id
  egress = true
  protocol   = -1
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

#Create public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-public-${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

#Associate public subnet in public routing table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#Associate public subnet in public NACL
resource "aws_network_acl_association" "public" {
  count = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  network_acl_id = aws_network_acl.public.id
}

# Creating EIP for NATGateway
resource "aws_eip" "nat" {
  vpc = true
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-natgateway",
      Environment = var.environment
    },
    var.tags
  )
}

# Creating NATGateway
resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-natgateway",
      Environment = var.environment
    },
    var.tags
  )
}

#Create application routing table
resource "aws_route_table" "application" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-app-rt",
      Environment = var.environment
    },
    var.tags
  )
}

#Add NAT Gateway entry in application routing table
resource "aws_route" "application" {
  route_table_id         = aws_route_table.application.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

#Creating application NACL
resource "aws_network_acl" "application" {
  vpc_id     = aws_vpc.default.id
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-application-nacl",
      Environment = var.environment
    },
    var.tags
  )
}

#Add ingress entry in application NACL
resource "aws_network_acl_rule" "application-ingress" {
  network_acl_id = aws_network_acl.application.id
  egress = false
  protocol   = -1
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

#Add egress entry in application NACL
resource "aws_network_acl_rule" "application-egress" {
  network_acl_id = aws_network_acl.application.id
  egress = true
  protocol   = -1
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

#Create application subnet
resource "aws_subnet" "application" {
  count = length(var.application_subnet_cidr_blocks)

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.application_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-app-${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

#Associate application subnet in application routing table
resource "aws_route_table_association" "application" {
  count = length(var.application_subnet_cidr_blocks)
  subnet_id      = aws_subnet.application[count.index].id
  route_table_id = aws_route_table.application.id
}

#Associate application subnet in application NACL
resource "aws_network_acl_association" "application" {
  count = length(var.application_subnet_cidr_blocks)
  subnet_id      = aws_subnet.application[count.index].id
  network_acl_id = aws_network_acl.application.id
}

#Create database routing table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-db-rt",
      Environment = var.environment
    },
    var.tags
  )
}

#Creating database NACL
resource "aws_network_acl" "database" {
  vpc_id     = aws_vpc.default.id
  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-database-nacl",
      Environment = var.environment
    },
    var.tags
  )
}

#Add ingress entry in database NACL
resource "aws_network_acl_rule" "database-ingress" {
  network_acl_id = aws_network_acl.database.id
  egress = false
  protocol   = -1
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

#Add egress entry in database NACL
resource "aws_network_acl_rule" "database-egress" {
  network_acl_id = aws_network_acl.database.id
  egress = true
  protocol   = -1
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

#Create database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr_blocks)

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.database_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "${var.customer_name}-${var.environment}-db-${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

#Associate database subnet in database routing table
resource "aws_route_table_association" "private" {
  count = length(var.database_subnet_cidr_blocks)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

#Associate database subnet in database NACL
resource "aws_network_acl_association" "database" {
  count = length(var.database_subnet_cidr_blocks)
  subnet_id      = aws_subnet.database[count.index].id
  network_acl_id = aws_network_acl.database.id
}