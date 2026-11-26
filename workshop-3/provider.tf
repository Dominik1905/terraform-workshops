provider "aws" {
  # Die Workshop-Ressourcen werden in Nord-Virginia angelegt.
  # Terraform verwendet das AWS-Profil aus unserem Terminal.
  region = "us-east-1"
}
