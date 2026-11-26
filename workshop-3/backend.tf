terraform {
  # Der Bucket-Name wird beim Initialisieren übergeben.
  backend "s3" {
    region = "us-east-1"

    # Beide Workflows greifen auf diese State-Datei zu.
    key     = "terraform-workshops/workshop-3/terraform.tfstate"
    encrypt = true

    # Die Sperrdatei verhindert gleichzeitige Änderungen am State.
    use_lockfile = true
  }
}
