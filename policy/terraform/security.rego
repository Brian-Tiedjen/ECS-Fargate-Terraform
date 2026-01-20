package main

deny[msg] {
  sg := resources[_]
  sg.type == "aws_security_group"
  ingress := sg.values.ingress[_]
  cidr := ingress.cidr_blocks[_]
  cidr == "0.0.0.0/0"
  ingress.from_port <= 22
  ingress.to_port >= 22
  msg := sprintf("Security group %s allows SSH from 0.0.0.0/0", [sg.address])
}

deny[msg] {
  bucket := resources[_]
  bucket.type == "aws_s3_bucket"
  not has_sse_resource
  msg := "S3 buckets exist but no aws_s3_bucket_server_side_encryption_configuration resource is present"
}

has_sse_resource {
  resources[_].type == "aws_s3_bucket_server_side_encryption_configuration"
}
