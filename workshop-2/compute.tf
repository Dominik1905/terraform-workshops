# Die Schnittstelle verbindet die Instanz mit dem Subnetz und der Security Group.
resource "aws_network_interface" "web" {
  count           = 1
  subnet_id       = aws_subnet.public[0].id
  private_ips     = ["10.20.1.10"]
  security_groups = [aws_security_group.web.id]
  tags            = { Name = "tf-w2-eni-1" }
}

# Die Elastic IP gibt der Schnittstelle eine feste öffentliche Adresse.
resource "aws_eip" "web" {
  count             = 1
  domain            = "vpc"
  network_interface = aws_network_interface.web[0].id
  depends_on        = [aws_internet_gateway.main]
  tags              = { Name = "tf-w2-eip-1" }
}

# Ubuntu startet auf einer t2.micro und nutzt die vorbereitete Schnittstelle.
resource "aws_instance" "web" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  primary_network_interface {
    network_interface_id = aws_network_interface.web[0].id
  }

  # Beim ersten Start installiert das Skript Apache und schreibt die Startseite.
  user_data                   = file("${path.module}/apache.sh")
  user_data_replace_on_change = true

  # Der Paketdownload braucht die Elastic IP, die wirksame Route und Egress.
  depends_on = [
    aws_eip.web,
    aws_route.internet,
    aws_route_table_association.public,
    aws_vpc_security_group_egress_rule.all
  ]

  tags = { Name = "tf-w2-web-1" }
}
