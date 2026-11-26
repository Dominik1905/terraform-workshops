terraform {
  # Der AWS-Provider setzt unsere Terraform-Konfiguration in AWS-Aufrufe um.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
