# The bootstrap environment
# all resources managed by terraform are tagged as such to assit in diagnosing errors

module "vpc-bootstrap" {
  source = "github.com/feedyard/terraform-aws-vpc?ref=v1.0.4"

  name = "${var.bootstrap-vpc-name}"
  cidr = "${var.bootstrap-cidr}"

  public_subnets = "${var.bootstrap-subnets}"
  azs = "${var.bootstrap-azs}"

  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags {
    "terraform" = "true"
    "bootstrap" = "true"
    "environment" = "${terraform.workspace}"
  }
}

# efs mount used for bootstrap instance storage
module "efs-bootstrap" {
  source = "github.com/feedyard/terraform-aws-efs"

  efs_name = "${var.bootstrap-efs-name}"
  vpc_id = "${module.vpc-bootstrap.vpc_id}"
  subnet_id = "${element(module.vpc-bootstrap.public_subnets, 1)}"

  security_groups = ["${module.sg-bootstrap-swarm.security_group_id}"]

  tags {
    "terraform" = "true"
    "bootstrap" = "true"
    "environment" = "${terraform.workspace}"
  }
}

# security group for bootstrap docker host instance
module "sg-bootstrap-swarm" {
  source = "github.com/feedyard/terraform-aws-sg//docker-swarm"


  security_group_name = "${var.bootstrap-instance-sg-name}"
  vpc_id = "${module.vpc-bootstrap.vpc_id}"
  source_cidr_block = "0.0.0.0/0"

  tags {
    "terraform" = "true"
    "bootstrap" = "true"
    "environment" = "${terraform.workspace}"
  }
}

# permissions for policy that will be attached to instance profile for bootstrap docker-host
resource "aws_iam_policy" "bootstrap_host_policy" {
  name = "${var.bootstrap-host-policy-name}"
  policy = "${file("./policy-json/BootstrapHost.json")}"
}

# role/instance profile definition
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bootstrap_host_role" {
  name               = "${var.bootstrap-host-role-name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_policy_attachment" "bootstrap_host_policy" {
  name      = "${var.bootstrap-host-policy-name}"
  roles      = ["${aws_iam_role.bootstrap_host_role.name}"]
  policy_arn = "${aws_iam_policy.bootstrap_host_policy.arn}"
}

resource "aws_iam_instance_profile" "bootstrap_host_profile" {
  name  = "${var.bootstrap-host-profile-name}"
  role = "${aws_iam_role.bootstrap_host_role.name}"
}

data "template_file" "user_data" {
  template = "${file("cloud-init_template")}"
  vars {
    "nfs_dns" = "${module.efs-bootstrap.efs_dns}"
  }
}

resource "aws_instance" "bootstrap01" {
  ami = "${var.bootstrap-node-ami}"
  instance_type = "${var.bootstrap-instance-type}"

  key_name = "${var.bootstrap-key-pair}"
  subnet_id = "${module.vpc-bootstrap.public_subnets[0]}"
  availability_zone = "${var.bootstrap-azs[0]}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${module.sg-bootstrap-swarm.security_group_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.bootstrap_host_profile.id}"
  monitoring = true
  user_data = "${data.template_file.user_data.rendered}"

  tags {
    Name = "${format("%s", var.bootstrap-instance-name)}"
    terraform = "true"
    bootstrap = "true"
    environment = "${terraform.workspace}"
  }
}
