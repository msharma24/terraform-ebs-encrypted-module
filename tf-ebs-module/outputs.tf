output "volume_id" {
  value = "${aws_ebs_volume.encrypted_volume.id}"
}

output "volume_arn" {
  value = "${aws_ebs_volume.encrypted_volume.arn}"
}

output "instance_id" {
  value = "${data.aws_instance.ec2_instance.id}"
}
