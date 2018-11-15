
variable "aws_region" {
  description = "AWS region to launch servers"
  default = "ap-south-1"
}

variable "ami" {
  description = "Ubuntu Server 16.04 LTS"
  default = "ami-188fba77"
}


variable "key_path" {
  description = "SSH Public Key path"
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  default = "terraform-ansible-example-key"
}
