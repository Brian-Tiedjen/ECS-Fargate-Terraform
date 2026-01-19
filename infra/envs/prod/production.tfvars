vpc_cidr = "10.2.0.0/16"

environment = "production"

public_subnets = {
  public-az1 = {
    cidr = "10.2.1.0/24"
    az   = "us-east-2a"
  }
  public-az2 = {
    cidr = "10.2.2.0/24"
    az   = "us-east-2b"
  }
}

private_subnets = {
  private-az1 = {
    cidr = "10.2.101.0/24"
    az   = "us-east-2a"
  }
  private-az2 = {
    cidr = "10.2.102.0/24"
    az   = "us-east-2b"
  }
}
