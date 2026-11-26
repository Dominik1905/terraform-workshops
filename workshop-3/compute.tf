# Jedes Subnetz bekommt eine ENI mit einer festen privaten IPv4-Adresse.
resource "aws_network_interface" "web" {
  count           = 2
  subnet_id       = aws_subnet.public[count.index].id
  private_ips     = ["10.20.${count.index + 1}.10"]
  security_groups = [aws_security_group.web.id]
  tags            = { Name = "tf-w3-eni-${count.index + 1}" }
}

# Jede ENI erhält eine Elastic IP, damit Ubuntu Pakete laden kann.
resource "aws_eip" "web" {
  count             = 2
  domain            = "vpc"
  network_interface = aws_network_interface.web[count.index].id
  depends_on        = [aws_internet_gateway.main]
  tags              = { Name = "tf-w3-eip-${count.index + 1}" }
}

# Pro Subnetz startet eine Ubuntu-Instanz mit der passenden Hauptschnittstelle.
resource "aws_instance" "web" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  primary_network_interface {
    network_interface_id = aws_network_interface.web[count.index].id
  }

  # Beide Instanzen installieren Apache mit demselben Startskript.
  user_data                   = file("${path.module}/apache.sh")
  user_data_replace_on_change = true

  # Der Internetzugang für den Paketdownload muss vor dem Start bereit sein.
  depends_on = [
    aws_eip.web,
    aws_route.internet,
    aws_route_table_association.public,
    aws_vpc_security_group_egress_rule.all
  ]

  tags = { Name = "tf-w3-web-${count.index + 1}" }
}
