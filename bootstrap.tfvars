{
  "bootstrap-aws-default-region" : "us-east-1",

  "bootstrap-vpc-name" : "vpc-bootstrap",
  "bootstrap-cidr" : "10.0.0.0/16",
  "bootstrap-subnets" : ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"],
  "bootstrap-azs" : ["us-east-1b","us-east-1c","us-east-1d"],

  "bootstrap-efs-name" : "efs-bootstrap",

  "bootstrap-instance-sg-name" : "vpc-sg-bootstrap-swarm",
  "bootstrap-host-policy-name" : "bootstrap-host-policy",
  "bootstrap-host-role-name" : "bootstrap-host-role",
  "bootstrap-host-profile-name" : "bootstrap-host-profile",

  "bootstrap-instance-name" : "bootstrap01",
  "bootstrap-instance-type" : "t2.micro",
  "bootstrap-node-ami" : "ami-d651b8ac",
  "bootstrap-key-pair" : "bootstrap",

  "bootstrap-instance-user" : "ubuntu",
  "bootstrap-instance-pem-file" : "bootstrap.pem"
}
