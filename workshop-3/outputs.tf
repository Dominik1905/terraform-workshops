# Gibt den geforderten öffentlichen DNS-Namen des Load Balancers aus.
output "load_balancer_dns" {
  value = aws_lb.web.dns_name
}

# Die vollständige Adresse vereinfacht den Browser-Test.
output "web_url" {
  value = "http://${aws_lb.web.dns_name}"
}

# Mit den IDs lassen sich die zwei Instanzen in der Zielgruppe wiederfinden.
output "instance_ids" {
  value = aws_instance.web[*].id
}
