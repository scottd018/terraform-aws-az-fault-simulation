data "aws_caller_identity" "current" {}

data "aws_availability_zones" "selected" {
  state = "available"

  filter {
    name   = "zone-name"
    values = [var.availability_zone]
  }
}

data "aws_vpc" "selected" {
  id = var.subnet_vpc_id
}
