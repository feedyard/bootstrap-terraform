terraform {
  required_version = ">= 0.10.6"

  backend "s3" {

    # CONFIRM: correct bucket and key path
    bucket = "feedyard-terraform-state"
    key    = "bootstrap/bootstrap.tfstate"
  }
}