Terraform-aws-Ansible

This Terraform configuration provisions an EC2 instance in AWS VPC and Ansible playbook provision launches hello world docker image.

Details

By default, this configuration provisions a Ubuntu 16.04 Base Image AMI (with ID ami-2e1ef954) with type t2.micro in the ap-south-1 region. The AMI ID, region, and type can all be set as variables. You can also set the name variable to determine the value set for the Name tag.

Once you.ve defined all the required templates, make sure to set the AWS credentials variables as an envrionment variables.

Initialization

The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is 

$ terraform init

Plans

$ terraform plan

Apply Changes

$ terraform apply
