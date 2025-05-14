module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"
  cluster_name = "tf-cluster"
  cluster_version = "1.32"

  vpc_id = var.tf-vpc-id

  subnet_ids = [
    var.tf-vpc-prv-sub1-id,
    var.tf-vpc-prv-sub2-id
  ]

  eks_managed_node_groups = {
    tf-cluster-nodegroups = {
        min_size = 2
        max_size = 4
        desired_size = 2
        instance_type = ["t3.micro"]
    }
  }

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
}