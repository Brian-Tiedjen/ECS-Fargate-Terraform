variable "environment" {
  type = string
}

variable "execution_policy_arns" {
  type    = list(string)
  default = []
}

variable "task_policy_arns" {
  type    = list(string)
  default = []
}
