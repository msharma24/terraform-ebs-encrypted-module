# terraform-ebs-encrypted-module
Terraform Module to created and  attach encrypted volumes to running instances

This module will create and attach an ecrypted volume to a running EC2 instance.
The EBS volume and instance needs to be in the same AZ.

*Example*

```hcl
module "encrypted_ebs" {
  source = "../tf-ebs-module"
  availability_zone = "us-east-1a"
  size  = "8"
  type ="gp2"
  iops = "100"
  kms_key_id = "arn:aws:kms:us-east-1:1111111:key/xxx-yyyy-zzz"
  encrypted = true
  instance_id  = "i-0d2801dc4c87d1186"
  device_name = "/dev/sdh"
  ```
