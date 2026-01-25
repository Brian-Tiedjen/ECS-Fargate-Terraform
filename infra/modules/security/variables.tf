variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_endpoint_sg_id" {
  type = string
}

variable "service_port" {
  type    = number
  default = 80
}

variable "alb_ingress_port" {
  type    = number
  default = 80
}

variable "alb_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
