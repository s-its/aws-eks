output "eks_cluster" {
  value = aws_eks_cluster.cluster
}

/*
output "aws_eks_node_group" {
  value = aws_eks_node_group.managed_nodes
}*/
