module "test" {
  source = "../"

  experiment_template_name = "dscott-test"
  availability_zone        = "us-east-1a"
  subnet_vpc_id            = "vpc-0addae65e492b4587"
  ec2_selected_tags = {
    "red-hat-managed" : "true",
    "api.openshift.com/id" : "2eg24j3hej8djd5m9e0e6vgm7s07v11b"
  }
  ebs_selected_tags = {
    "red-hat-managed" : "true"
    "api.openshift.com/name" : "dscott"
  }
}
