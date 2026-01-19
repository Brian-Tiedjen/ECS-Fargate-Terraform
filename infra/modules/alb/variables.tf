variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "logs_bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "listener_port" {
  type    = number
  default = 80
}

variable "target_port" {
  type    = number
  default = 8000
}
