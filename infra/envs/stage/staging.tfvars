vpc_cidr = "10.1.0.0/16"

environment = "staging"

public_subnets = {
  public-az1 = {
    cidr = "10.1.1.0/24"
    az   = "us-east-2a"
  }
  public-az2 = {
    cidr = "10.1.2.0/24"
    az   = "us-east-2b"
  }
}

private_subnets = {
  private-az1 = {
    cidr = "10.1.101.0/24"
    az   = "us-east-2a"
  }
  private-az2 = {
    cidr = "10.1.102.0/24"
    az   = "us-east-2b"
  }
}

alarm_email_subscriptions = ["briantiedjen@gmail.com"]
