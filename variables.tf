variable "environment" {
  type    = string
  default = "dev"
}
variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_cidr" {
  type = string
}
variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}
variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}
