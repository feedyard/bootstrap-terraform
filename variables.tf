terraform {
  required_version = ">= 0.10.6"

  backend "s3" {

    # CONFIRM: correct bucket and key path
    bucket = "feedyard-terraform-state"
    key    = "bootstrap/bootstrap.tfstate"
  }
}

variable "bootstrap-aws-default-region" {}

variable "bootstrap-vpc-name" {}
variable "bootstrap-cidr" {}
variable "bootstrap-subnets" { type = "list" }
variable "bootstrap-azs" { type = "list" }