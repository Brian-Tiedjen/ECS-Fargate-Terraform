variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
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
  default = 75
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
