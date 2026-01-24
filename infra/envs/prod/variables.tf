variable "environment" {
  type    = string
  default = "prod"
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

variable "alb_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 6
}

variable "cpu_target_value" {
  type    = number
  default = 55
}

variable "memory_target_value" {
  type    = number
  default = 70
}

variable "scale_in_cooldown" {
  type    = number
  default = 180
}

variable "scale_out_cooldown" {
  type    = number
  default = 60
}

variable "alarm_topic_name" {
  type    = string
  default = ""
}

variable "alarm_email_subscriptions" {
  type    = list(string)
  default = []
}

variable "cpu_high_threshold" {
  type    = number
  default = 70
}

variable "memory_high_threshold" {
  type    = number
  default = 80
}

variable "evaluation_periods" {
  type    = number
  default = 2
}

variable "period_seconds" {
  type    = number
  default = 60
}

variable "enable_dashboard" {
  type    = bool
  default = true
}

variable "dashboard_name" {
  type    = string
  default = ""
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "image_tag" {
  type    = string
  default = "production"
}
