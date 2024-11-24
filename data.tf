data "aws_ami" "eks_base" {
  owners      = ["619071318818"]
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["base-eks-image"]
  }

}