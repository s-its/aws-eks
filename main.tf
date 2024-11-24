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

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge({
    Name        = var.cluster_name
    Environment = var.environment
    },
    var.tags
  )
}

# Managed Node Group
resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.node_group.desired_node
    max_size     = var.node_group.max_node
    min_size     = var.node_group.min_node
  }

  ami_type        = var.node_group.ami_type
  release_version = data.aws_ami.eks_base.id

  capacity_type  = var.node_group.capacity_type
  disk_size      = var.node_group.disk_size
  instance_types = var.node_group.instance_types




  tags = merge({
    Name        = local.node_group_name
    Environment = var.environment
    },
    var.tags
  )
}



# Optional X-Ray Addon
resource "aws_eks_addon" "xray" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "aws-xray"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags

  count = var.enable_xray ? 1 : 0
}

# Istio Installation
resource "null_resource" "istio_install" {
  provisioner "local-exec" {
    command = <<EOT
    curl -L https://istio.io/downloadIstio | sh -
    cd istio-*
    export PATH=$PATH:$PWD/bin
    istioctl install --set profile=demo -y
    EOT
  }

  count = var.enable_istio ? 1 : 0
}

# Calico Network Policies
resource "null_resource" "calico_install" {
  provisioner "local-exec" {
    command = <<EOT
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    EOT
  }
}

# Prometheus and Grafana Installation
resource "null_resource" "monitoring" {
  provisioner "local-exec" {
    command = <<EOT
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prometheus prometheus-community/prometheus
    helm install grafana grafana/grafana
    EOT
  }

  count = var.enable_monitoring ? 1 : 0
}

# AWS SSO Integration
/*resource "null_resource" "aws_sso_users" {
  provisioner "local-exec" {
    command = <<EOT
    aws configure sso
    aws sso login
    kubectl create clusterrolebinding sso-admin-binding --clusterrole=cluster-admin --user=<SSO_USER_ARN>
    EOT
  }
}*/

resource "null_resource" "aws_sso_roles" {
  provisioner "local-exec" {
    command = <<EOT
    aws eks update-kubeconfig --name ${aws_eks_cluster.cluster.name}

    # Map the SSO roles to Kubernetes roles in the aws-auth configmap
    kubectl patch configmap aws-auth -n kube-system --patch "$(cat <<EOF
    data:
      mapRoles: |
        - rolearn: ${var.admin_role_arn}
          username: admin
          groups:
            - system:masters
        - rolearn: ${var.view_role_arn}
          username: view
          groups:
            - view-group
    EOF
    )"
    EOT
  }
}

resource "null_resource" "admin_view_roles" {
  provisioner "local-exec" {
    command = <<EOT
    kubectl apply -f ./k8s-admin-view-roles.yaml
    EOT
  }
}
