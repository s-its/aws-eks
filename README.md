# aws-eks


```hcl
cluster_name       = "my-eks-cluster"
private_subnets    = ["subnet-1234abcd", "subnet-5678efgh", "subnet-9101ijkl"]
environment        = "production"
enable_xray        = false
enable_istio       = false
enable_monitoring  = false
admin_role_arn     = "arn:aws:iam::123456789012:role/<role admin name>"
view_role_arn      = "arn:aws:iam::123456789012:role/<role view name>"
tags               = {}
node_group         = {
                      desired_node = 2
                      max_node = 4
                      min_node = 1
                      ami_type = "CUSTOM"
                      capacity_type = "SPOT" # allowed value is "SPOT" and "ON_DEMAND"
                      disk_size = 30
                      instance_types = ["t3.medium"]
                    }

```