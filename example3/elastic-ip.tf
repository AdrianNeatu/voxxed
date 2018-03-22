resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.example.id}"
  allocation_id = "${aws_eip.voxxed_ip.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "voxxed_ip" {}
