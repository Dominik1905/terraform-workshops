# Den öffentlichen DNS-Namen geben wir für die Aufgabenstellung aus.
output "public_dns" {
  value = aws_instance.web.public_dns
}

# Die vollständige HTTP-Adresse kann direkt im Browser geöffnet werden.
output "web_url" {
  value = "http://${aws_instance.web.public_dns}"
}
