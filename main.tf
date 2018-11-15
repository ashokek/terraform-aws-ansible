
# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}


# Define our VPC

resource "aws_vpc" "default" {
    enable_dns_support = true
    enable_dns_hostnames = true
    cidr_block = "10.0.0.0/16"
tags {
    Name = "terraform-vpc"
  }
}


# Define the internet gateway

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

tags {
    Name = "VPC IGW"
  }
}


# Define the route table

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}



# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

tags {
    Name = "Web Public Subnet"
  }
}


# Our default security group to access
# the instances over SSH and HTTP

resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

 # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# Define the security group for public subnet

resource "aws_security_group" "web" {
    name = "terraform-web-instance"
    vpc_id = "${aws_vpc.default.id}"


    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      ipv6_cidr_blocks = ["::/0"]
    }
}


# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "${var.key_name}"
  public_key = "${file("${var.key_path}")}"
}


# Define webserver inside the public subnet
resource "aws_instance" "web" {

   connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
    }

   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${var.key_name}"
   subnet_id = "${aws_subnet.default.id}"
   vpc_security_group_ids = ["${aws_security_group.default.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("install.sh")}"   

  tags {
    Name = "webserver"
  }
 }


#Associate Elastic IP

resource "aws_eip" "lb" {
  instance = "${aws_instance.web.id}"
  depends_on = ["aws_instance.web"] 
 vpc      = true


##This is where we configure the instance with ansible-playbook

provisioner "local-exec" {
        command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu  -i '${aws_eip.lb.public_ip},' provision.yml"
   }

}







