## CREATE IAM ROLE
resource "aws_iam_role" "main" {
  name               = var.iam_role_name
  assume_role_policy = var.assume_role_policy

  tags = merge(
    {
      Name = var.iam_role_name
    },
    var.iam_role_tags,
    var.common_tags,
  )
}

## CREATE IAM POLICY
resource "aws_iam_policy" "main" {
  count  = var.iam_policy_name == null ? 0 : 1
  name   = var.iam_policy_name
  policy = var.policies
}

## ATTACH POLICY TO IAM ROLE
resource "aws_iam_role_policy_attachment" "aws_managed" {
  count      = length(var.aws_managed_policy_arns)
  role       = aws_iam_role.main.name
  policy_arn = var.aws_managed_policy_arns[count.index]
}

resource "aws_iam_role_policy_attachment" "customer_managed" {
  count      = var.iam_policy_name == null ? 0 : 1
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.0.arn
}
