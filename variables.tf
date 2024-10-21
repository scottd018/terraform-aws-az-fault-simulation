variable "experiment_template_name" {
  type        = string
  description = "The experiment teamplate name that is created in AWS FIS.  It is important to note that the availability zone will be added to the end of the name."
  default     = "az-fault-experiment"
}

variable "duration_minutes" {
  type        = number
  description = "Duration in which each experiment will run.  Experiments are run sequentially to test individual outages. [1,5,10,15,30,45,60]"
  default     = 1

  validation {
    condition     = contains([1, 5, 10, 15, 30, 45, 60], var.duration_minutes)
    error_message = "Duration must be one of 1,5,10,15,30,45,60."
  }
}

variable "availability_zone" {
  type        = string
  description = "Availability zone to disrupt for testing faults."
}

variable "tags" {
  description = "Tags applied to all objects."
  type        = map(string)
  default     = {}
}

variable "ec2_selected_tags" {
  description = "Tags to filter affected EC2 instances that exist in var.availability_zone. WARN: these will be terminated."
  type        = map(string)
  default     = {}
}

variable "ebs_selected_tags" {
  description = "Tags to filter affected EBS volumes. WARN: IO will be stopped to these volumes."
  type        = map(string)
  default     = {}
}

variable "subnet_vpc_id" {
  description = "VPC ID in which subnets will be disruped.  WARN: all subnets from var.availability_zone will be disrupted."
  type        = string
}
