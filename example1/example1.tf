provider "aws" {
  region     = "us-east-1"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.example.id}"
  instance_id = "${aws_instance.example.id}"
}

resource "aws_instance" "example" {
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  count = 1
}

resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1a"
  size = 2
  tags {
    Name = "HelloWorld"
  }
}
