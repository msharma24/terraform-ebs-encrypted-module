resource "aws_ebs_volume" "encrypted_volume" {
  availability_zone = "${var.availability_zone}"

  size = "${var.size}"
  type = "${var.type}"
  iops = "${var.iops}"
  size = "${var.size}"

  encrypted  = "${var.encrypted}"
  kms_key_id = "${var.kms_key_id}"
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "${var.device_name}"
  volume_id   = "${aws_ebs_volume.encrypted_volume.id}"
  instance_id = "${data.aws_instance.ec2_instance.id}"
}

data "aws_instance" "ec2_instance" {
  instance_id = "${var.instance_id}"
}
