# Zeigt die öffentliche IP an, die AWS der Schnittstelle zugewiesen hat.
output "public_ip" {
  value = aws_eip.web[0].public_ip
}

# Baut daraus die Adresse für den Browser-Test.
output "web_url" {
  value = "http://${aws_eip.web[0].public_ip}"
}
