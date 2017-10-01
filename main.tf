# The bootstrap environment
# all resources managed by terraform are tagged as such to assit in diagnosing errors

module "vpc-bootstrap" {
  source = "github.com/feedyard/terraform_aws_vpc"

  name = "${var.bootstrap-vpc-name}"
  cidr = "${var.bootstrap-cidr}"

  public_subnets = "${var.bootstrap-subnets}"
  azs = "${var.bootstrap-azs}"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    "terraform" = "true"
    "bootstrap" = "true"
    "environment" = "${terraform.env}"
  }
}