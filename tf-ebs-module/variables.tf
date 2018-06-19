variable "availability_zone" {}
variable "size" {}
variable "type" {}
variable "iops" {}
variable "kms_key_id" {}

variable "encrypted" {
  default = true
}

variable "instance_id" {}
variable "device_name" {
}
