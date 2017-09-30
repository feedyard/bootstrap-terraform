# bootstrap-terraform

# bootstrap_tf

(Note: See notes in feedyard/documentation regarding similar project published by the ThoughtWorks Digital Platform Strategy product team.)

As part of a greenfield build of an example platform-as-a-service style product based on Kubernetes, bootstrap-terraform creates the initial aws infrastructure to support the automated orchestration of the complete platform.  
It is recommended that the bootstrap environment be implemented in the AWS account used for production since this is typically the most protected account with the least potential number of IAM users.

There are several dependencies or requirements necessary to use this configuration. See the section below prior to implementing.









### Implementation

Create a new bootstrap repo with a complete copy of bootstrap_tf.

Review `bootstrap.tfvars` to confirm the following:
* correct bucket and folder names for the tfstate files in s3 (it is recommend to maintain separate state files for the bootstrap env as it is part of DR)
* the custom names selected for the specific resources
* the appropriate cidr for use in your org architecture design

Review `main.tf` to confirm the following:
* correct repo names for the org clones of the community-terraform-modules

This example places all terraform Name parameters into a tfvar folder rather than inline in main.tf
This enables a simple json readable desired state configuration that is used when provisioning the bootstrap host and other monitoring or testing.

*Security Note*: this reference assumes that public ingress is permitted via https for access to the orchestration tooling that will be deployed as part of the bootstrap process. You may wish to adopt a different security approach such as access only via a bastion host or other similarly more restrictive strategy.<br />

Initialize terraform to confirm remote state location and create the bootstrap env definition. Assumes AWS Environment credentials.
```bash
$ terraform init -var-file=./bootstrap.tfvars
$ terraform env new bootstrap
```

Perform the spec tests to confirm testability. At this stage naturally the tests will all fail.
```bash
$ bundle exec rspec spec
```

Run terraform Plan to review the changes that will happen to the account as a result of applying the plan.
```bash
$ terraform get
$ terraform plan -var-file=./bootstrap.tfvars
```
When ready you may execute `apply` to make the changes.
```bash
$ terraform apply -var-file=./bootstrap.tfvars
```

Run the spec test again to confirm the changes were successful.

There are Invoke commands available to assist in the above steps. See tasks.py for further information. Invoke tasks will be used to complete this bootstrap process.

At this point the bootstrap network location, efs mount point, and bootstrap host node are created and available.

Note* unresolved bug: during the provision of this node, the mount command to add the efs mount fails, however the efs volume is available upon reboot. This happens whether the efs mount was previous available or during single run to create everything. 

The next step is the secure the docker daemon, initialize the host as a docker swarm, and store the access keys as secrets in the swarm to support the baseline orchestration step.


the Invoke Prep task uses docker-machine to install docker and to secure the daemon with self-signed keys.
```bash
$ invoke prep
```

Initialize the secured host as a swarm.
```bash
$ invoke swarm
```

Store the new secure keys as secrets on the swarm so that upcoming deployment pipeline tasks can use them.
```bash
$ invoke secrets
```

TODO: Change ami to the secure, org-specific base docker ami once created.

### Dependencies

• AWS credentials with appropriate permissions.  
• IAM key pair has been created to associate with the instance and the .pem file is in the local directory.  
• An S3 bucket has been created as a remote store for tfstate, and the User or service account used to execute terraform commands must also be explicitly granted access to the bucket. Attaching a policy with the following definition is one method.  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::[bucket-name]/*",
      "Principal": {
        "AWS": [
          "arn:aws:iam::[account]:user/[bootstrap-user]"
        ]
      }
    }
  ]
}
```
• Installed locally:

[python3](https://www.python.org/)  
```bash
$ pip install invoke, boto3
```
[Ruby](https://www.ruby-lang.org/en/)  
```bash
# required gems
$ bundle install
```
[Terraform](https://www.terraform.io)  


##### note on keys

There are a a few keys that are assumed to be available or created by this process. You will need a secure method of storing and distributing these keys.
1password for teams is an example of a simple method.

##### GitHub repositories

Reference Implementation terraform automation often makes use of terrafrom modules via github/org/<repositories>.<br />

While many helpful community modules are available, the best practice is to create copies of these modules in an org-specific repo and pull/test changes from the public source rather than deploying directly. The feedyard convention is to include community-terraform-modules using the prefix "tfcm-"