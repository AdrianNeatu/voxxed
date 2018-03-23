provider "aws" {
  region     = "us-east-1"
}

resource "aws_key_pair" "adrian" {
  key_name   = "adrian"
  public_key = "${file("~/.ssh/aws.pub")}"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.adrian.key_name}"
  security_groups = ["${aws_security_group.allow_all.name}"]

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  tags {
    Name = "HelloWorld"
  }

//  lifecycle {
//    create_before_destroy = true
//  }
}
