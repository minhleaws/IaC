## REF: https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html
## CREATE IAM ROLE
resource "aws_iam_role" "main" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.openid_connect_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.openid_connect_provider_url, "https://", "")}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account}"
          }
        }
      }
    ]
  })

  tags = merge(
    { Name = var.iam_role_name },
    var.iam_role_tags,
    var.common_tags,
  )
}

## CREATE IAM POLICY
resource "aws_iam_role_policy" "main" {
  name   = var.iam_policy_name
  role   = aws_iam_role.main.id
  policy = var.policy
}
