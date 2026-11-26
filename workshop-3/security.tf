# Die Security Group gilt für den Webserver im neuen Netz.
resource "aws_security_group" "web" {
  name_prefix = "tf-w3-web-"
  description = "HTTP access for the Terraform web server"
  vpc_id      = aws_vpc.main.id
}

# Die Webserver akzeptieren HTTP nur von der Security Group des Load Balancers.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Ausgehender IPv4-Verkehr ist frei, damit Ubuntu Pakete laden kann.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
