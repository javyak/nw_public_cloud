# IAM configuration. Group operators for read only reusing existing AWS EC2 policy.

resource "aws_iam_group" "operators" {
  name = "operators"
}

resource "aws_iam_user" "pepito" {
  name = "pepito"
}

resource "aws_iam_access_key" "pepito_key" {
  user = aws_iam_user.pepito.name
}

resource "aws_iam_group_membership" "operators" {
  name = "tf-read-only-group"

  users = [
    aws_iam_user.pepito.name,
  ]

  group = aws_iam_group.operators.name
}

resource "aws_iam_group_policy_attachment" "read_only" {
  group      = aws_iam_group.operators.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# IAM configuration. Creates the role required for the Cloudwatch agent
resource "aws_iam_role" "cloudwatch_agent" {
  name = "cloudwatch_agent"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name = "cloudwatch_agent"
  role = aws_iam_role.cloudwatch_agent.name
}
