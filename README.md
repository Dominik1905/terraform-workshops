# Terraform Workshop auf AWS

Git Repo:

https://github.com/Dominik1905/terraform-workshops

- Terraform 1: Apache auf EC2 in der Default VPC
- Terraform 2: Eigene VPC mit Netzwerkschnittstelle und Elastic IP
- Terraform 3: Zwei EC2-Instanzen hinter einem Application Load Balancer
  mit manuellen GitHub-Workflows zum Erstellen und Löschen

## Why do we need Terraform Cloud or another backend when we use CI/CD?

Terraform merkt sich im State, welche AWS-Ressource zu welchem Block
im Code gehört. GitHub Actions startet für jeden Workflow einen neuen
Runner. Eine lokale State-Datei eines früheren Runners steht dem
nächsten Lauf deshalb nicht zur Verfügung.

In diesem Workshop bewahrt S3 den State zwischen den Läufen auf. Der
Apply-Workflow schreibt ihn, und der Destroy-Workflow liest ihn später,
um dieselben Ressourcen wiederzufinden. Die aktivierte Sperre verhindert
gleichzeitige Änderungen. HCP Terraform, früher Terraform Cloud, wäre
eine weitere Möglichkeit, denselben State zentral bereitzustellen.
