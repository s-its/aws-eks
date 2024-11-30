locals {
  node_group_name = "${var.cluster_name}-default-node-group"
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.main.arn

  vpc_config {
    subnet_ids = var.private_subnets
  }

  #  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = merge({
    Name        = var.cluster_name
    Environment = var.environment
    },
    var.tags
  )
}

# Launch template

/*resource "aws_launch_template" "eks_node_group" {
  name_prefix = "${var.cluster_name}-node-group"
  image_id    = data.aws_ami.eks_base.id

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.node_group.disk_size
      volume_type = "gp3"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.cluster_name}-node"
      Environment = var.environment
    }
  }
}*/


# Managed Node Group
resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnets
  version         = aws_eks_cluster.cluster.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  scaling_config {
    desired_size = var.node_group.desired_node
    max_size     = var.node_group.max_node
    min_size     = var.node_group.min_node
  }

  #  ami_type = var.node_group.ami_type
  #  launch_template {
  #    id      = aws_launch_template.eks_node_group.id
  #    version = "$Latest"
  #  }

  update_config {
    max_unavailable = 1
  }

  capacity_type  = var.node_group.capacity_type
  instance_types = var.node_group.instance_types
  disk_size  = var.node_group.disk_size

  tags = merge({
    Name        = local.node_group_name
    Environment = var.environment
    },
    var.tags
  )
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

# Optional X-Ray Addon
resource "aws_eks_addon" "xray" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "aws-xray"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags

  count = var.enable_xray ? 1 : 0
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = var.admin_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_role_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "view" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = var.view_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "view" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
  principal_arn = var.view_role_arn

  access_scope {
    type = "cluster"
  }
}


