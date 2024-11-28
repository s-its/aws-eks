data "aws_ami" "eks_base" {
  owners      = ["619071318818"]
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["base-eks-image"]
  }

}

data "aws_iam_policy_document" "ebs_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}