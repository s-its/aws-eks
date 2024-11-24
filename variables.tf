variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for the cluster"
}

variable "environment" {
  type        = string
  description = "Environment for tagging"
  default     = "production"
}

variable "enable_xray" {
  type        = bool
  description = "Flag to enable or disable X-Ray monitoring"
  default     = false
}

variable "enable_istio" {
  type        = bool
  description = "Flag to enable or disable Istio installation"
  default     = false
}

variable "enable_monitoring" {
  type        = bool
  description = "Flag to enable or disable Prometheus and Grafana"
  default     = false
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "node_group" {
  description = "AWS EKS Default node group"
  type = object({
    desired_node = number
    max_node = number
    min_node = number
    ami_type = string
    capacity_type = string
    disk_size = number
    instance_types = list(string)
  })
  default = {
    desired_node = 2
    max_node = 4
    min_node = 1
    ami_type = "CUSTOM"
    capacity_type = "SPOT"
    disk_size = 30
    instance_types = ["t3.medium"]
  }
}

variable "admin_role_arn" {
  type        = string
  description = "ARN of the SSO Admin Role"
  default = "arn:aws:iam::619071318818:role/aws-reserved/sso.amazonaws.com/ap-south-1/AWSReservedSSO_AdministratorAccess_2dcbee0933887667"
}

variable "view_role_arn" {
  type        = string
  description = "ARN of the SSO View Role"
  default = "arn:aws:iam::619071318818:role/aws-reserved/sso.amazonaws.com/ap-south-1/AWSReservedSSO_ReadOnlyAccess_929f08f88e22f0df"
}

