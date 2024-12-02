resource "aws_iam_role" "ec2_ssm" {
  name = "ec2_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = var.policy_arn
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_iam_policy" "ec2_s3" {
  name        = "ec2_s3_policy"
  description = "Allow webserver to read, write, list and update images"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.startup_image_bucket.id}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attach-s3" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.ec2_s3.arn
}

resource "aws_iam_policy" "ec2_ssm_parameter" {
  name        = "ec2_ssm_parameter_policy"
  description = "Allow webserver to read SSM parameter store"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeParameter",
          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/cloudtalents/startup/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attach-ssm-parameter" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.ec2_ssm_parameter.arn
}
