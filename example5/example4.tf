provider "aws" {
  region     = "us-east-1"
}

resource "aws_autoscaling_group" "asg_app" {
  lifecycle { create_before_destroy = true }

  # spread the app instances across the availability zones
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # interpolate the LC into the ASG name so it always forces an update
  name = "asg-app - ${aws_launch_configuration.lc_app.name}"
  max_size = 4
  min_size = 2
  wait_for_elb_capacity = 2
  desired_capacity = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.lc_app.id}"
  load_balancers = ["${aws_elb.lb.id}"]
  termination_policies = ["OldestLaunchConfiguration"]
  vpc_zone_identifier = ["subnet-1793e238", "subnet-6bbf8120", "subnet-3e4b3e63"]
}

resource "aws_launch_configuration" "lc_app" {
  lifecycle { create_before_destroy = true }

  image_id = "ami-2757f631"
  instance_type = "t2.micro"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.allow_all.id}"]
  key_name = "${aws_key_pair.adrian.key_name}"
}

resource "aws_elb" "lb" {
  name               = "terraform-elb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = ["${aws_instance.example.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = ["${aws_security_group.allow_all.id}"]

  tags {
    Name = "terraform-elb"
  }
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

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("~/.ssh/aws")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
