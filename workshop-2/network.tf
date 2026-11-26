# AWS liefert die verfügbaren Zonen, aus denen wir eine für das Subnetz wählen.
data "aws_availability_zones" "available" {
  state = "available"
}

# Diese VPC stellt den privaten IPv4-Adressbereich für Teil 2 bereit.
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "tf-w2-vpc" }
}

# Das Gateway verbindet unsere VPC mit dem Internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "tf-w2-igw" }
}

# Die eigene Routingtabelle enthält die Regeln für unser Subnetz.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "tf-w2-public" }
}

# IPv4-Ziele ohne spezifischere Route gehen über das Internet Gateway.
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Das Subnetz reserviert 10.20.1.0/24 für den Webserver.
resource "aws_subnet" "public" {
  count             = 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  # Die öffentliche Adresse weisen wir im nächsten Schritt als Elastic IP zu.
  map_public_ip_on_launch = false
  tags                    = { Name = "tf-w2-public-1" }
}

# Diese Zuordnung macht unsere Routingtabelle für das Subnetz wirksam.
resource "aws_route_table_association" "public" {
  count          = 1
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public.id
}
