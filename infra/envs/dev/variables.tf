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

variable "service_port" {
  type    = number
  default = 8000
}

variable "alb_listener_port" {
  type    = number
  default = 80
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}
