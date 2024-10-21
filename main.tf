locals {
  experiment_template_name = "${var.experiment_template_name}-${data.aws_availability_zones.selected.names[0]}"
  experiment_template_tags = merge(var.tags, { "experiment" = "selected", "Name" = local.experiment_template_name })

  # derive duration value from input
}

resource "aws_fis_experiment_template" "az_failure" {
  description = local.experiment_template_name
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  # pause volume io
  action {
    name      = "action-pause-ebs-volume-io"
    action_id = "aws:ebs:pause-volume-io"

    target {
      key   = "Volumes"
      value = "target-pause-ebs-volume-io"
    }

    parameter {
      key   = "duration"
      value = "PT${var.duration_minutes}M"
    }
  }

  target {
    name           = "target-pause-ebs-volume-io"
    resource_type  = "aws:ec2:ebs-volume"
    selection_mode = "ALL"

    dynamic "resource_tag" {
      for_each = var.ebs_selected_tags

      content {
        key   = resource_tag.key
        value = resource_tag.value
      }
    }

    parameters = {
      "availabilityZoneIdentifier" = data.aws_availability_zones.selected.names[0]
    }
  }

  # terminate instances
  action {
    name        = "action-terminate-ec2-instances"
    action_id   = "aws:ec2:terminate-instances"
    start_after = ["action-pause-ebs-volume-io"]

    target {
      key   = "Instances"
      value = "target-terminate-ec2-instances"
    }
  }

  target {
    name           = "target-terminate-ec2-instances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"

    dynamic "resource_tag" {
      for_each = var.ec2_selected_tags

      content {
        key   = resource_tag.key
        value = resource_tag.value
      }
    }

    filter {
      path   = "State.Name"
      values = ["running"]
    }

    filter {
      path   = "Placement.AvailabilityZone"
      values = [data.aws_availability_zones.selected.names[0]]
    }
  }

  # disrupt network connectivity
  action {
    name        = "action-disrupt-network-connectivity"
    action_id   = "aws:network:disrupt-connectivity"
    start_after = ["action-terminate-ec2-instances"]

    target {
      key   = "Subnets"
      value = "target-disrupt-network-connectivity"
    }

    parameter {
      key   = "duration"
      value = "PT${var.duration_minutes}M"
    }

    parameter {
      key   = "scope"
      value = "all"
    }
  }

  target {
    name           = "target-disrupt-network-connectivity"
    resource_type  = "aws:ec2:subnet"
    selection_mode = "ALL"

    parameters = {
      "availabilityZoneIdentifier" = data.aws_availability_zones.selected.names[0]
      "vpc"                        = data.aws_vpc.selected.id
    }
  }

  tags = local.experiment_template_tags
}
