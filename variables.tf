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

variable "bootstrap-efs-name" {}

variable "bootstrap-instance-sg-name" {}
variable "bootstrap-host-policy-name" {}
variable "bootstrap-host-role-name" {}
variable "bootstrap-host-profile-name" {}

variable "bootstrap-instance-name" {}
variable "bootstrap-instance-type" {}
variable "bootstrap-node-ami" {}
variable "bootstrap-key-pair" {}

variable "bootstrap-instance-pem-file" {}
variable "bootstrap-instance-user" {}