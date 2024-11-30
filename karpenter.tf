resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"

  set {
    name  = "serviceAccount.annotations.eks.amazonaws.com/role-arn"
    value = aws_iam_role.karpenter_role.arn
  }

  create_namespace = true
}

resource "aws_iam_role" "karpenter_role" {
  name = "karpenter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "karpenter.sh"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
