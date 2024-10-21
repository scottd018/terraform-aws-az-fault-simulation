resource "aws_iam_role" "fis_role" {
  name = "fis-${local.experiment_template_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "fis.amazonaws.com"
        }
      }
    ]
  })
}

# allow all fis actions for the experiment
resource "aws_iam_policy" "fis_action_policy" {
  name        = "fis-${local.experiment_template_name}-action-policy"
  description = "Policy to allow actions only on the FIS experiment with experiment=selected tags."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowFISSpecificExperiment"
        Effect   = "Allow"
        Action   = "fis:*"
        Resource = "arn:aws:fis:*:${data.aws_caller_identity.current.account_id}:experiment/*"
        Condition = {
          "StringEquals" = {
            "aws:ResourceTag/experiment" = "selected"
          }
        }
      }
    ]
  })
}

locals {
  tag_conditions = {
    for key, value in var.ebs_selected_tags : "aws:ResourceTag/${key}" => value
  }
}

# allow ebs actions for the experiment
resource "aws_iam_policy" "ebs_policy" {
  name        = "fis-${local.experiment_template_name}-ebs-policy"
  description = "Policy to allow FIS to operate on specific EBS volumes."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:PauseVolumeIO"
        ],
        Resource = "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:volume/*",
        Condition = {
          "StringEquals" = local.tag_conditions
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fis_ec2_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access"
}

resource "aws_iam_role_policy_attachment" "fis_ecs_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorECSAccess"
}

resource "aws_iam_role_policy_attachment" "fis_eks_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEKSAccess"
}

resource "aws_iam_role_policy_attachment" "fis_network_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorNetworkAccess"
}

resource "aws_iam_role_policy_attachment" "fis_rds_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorRDSAccess"
}

resource "aws_iam_role_policy_attachment" "fis_ssm_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorSSMAccess"
}

resource "aws_iam_role_policy_attachment" "fis_cloudwatch_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "fis_action_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = aws_iam_policy.fis_action_policy.arn
}

resource "aws_iam_role_policy_attachment" "fis_ebs_policy" {
  role       = aws_iam_role.fis_role.name
  policy_arn = aws_iam_policy.ebs_policy.arn
}
