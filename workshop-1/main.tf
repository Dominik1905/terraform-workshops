# Terraform liest die vorhandene Default VPC.
data "aws_vpc" "default" {
  default = true
}

# Die Instanz soll in einem Standardsubnetz dieser VPC liegen.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Die eigene Security Group gilt für unseren Webserver.
resource "aws_security_group" "web" {
  name_prefix = "tf-w1-web-"
  description = "HTTP access for the Terraform web server"
  vpc_id      = data.aws_vpc.default.id
}

# Browser dürfen Apache über TCP-Port 80 erreichen.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Alle ausgehenden IPv4-Verbindungen sind erlaubt, etwa für Paketdownloads.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Die Ubuntu-Instanz bekommt eine öffentliche IP und die Webserver-Regeln.
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  # EC2 führt dieses Skript beim ersten Start aus.
  user_data                   = file("${path.module}/apache.sh")
  user_data_replace_on_change = true

  # Die ausgehende Regel muss vor dem Start für den Paketdownload bereit sein.
  depends_on = [aws_vpc_security_group_egress_rule.all]

  # Unter diesem Namen findest du die Instanz später in der AWS-Konsole.
  tags = { Name = "tf-w1-web" }
}
