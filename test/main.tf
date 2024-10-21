module "test" {
  source = "../"

  experiment_template_name = "dscott-test"
  availability_zone        = "us-east-1a"
  subnet_vpc_id            = "vpc-03bdf9b38e7e579f9"

  ec2_selected_tags = {
    "red-hat-managed" : "true",
    "api.openshift.com/name" : "dscott-fis"
  }
  ebs_selected_tags = {
    "red-hat-managed" : "true"
    "api.openshift.com/name" : "dscott-fis"
  }
}
