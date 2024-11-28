resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.3-eksbuild.2"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = "v1.3.4-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.31.2-eksbuild.3"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.19.0-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.37.0-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
  pod_identity_association = {
    role_arn = aws_iam_role.ebs_csi_driver_role.arn
    service_account= "kube-system:ebs-csi-controller-sa"
  }
}