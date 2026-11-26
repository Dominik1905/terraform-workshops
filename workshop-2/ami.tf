# Die Besitzer-ID stellt sicher, dass das Image von Canonical stammt.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  # Der Name grenzt die Suche auf Ubuntu 24.04 LTS Server für amd64 ein.
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
