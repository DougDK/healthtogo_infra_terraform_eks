resource "aws_eks_cluster" "cluster" {
  name     = "${var.env}-eks"
  version  = var.eks_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids = ["sg-094c74c3f60c64878"]
    subnet_ids         = ["subnet-0f1699d5cfa2cd5f5","subnet-020ec1dd449cf73a4","subnet-07fce9c6ca7181c53","subnet-086ba8ac0c970b6b2"]
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "node-group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.env}-eks-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = ["subnet-0f1699d5cfa2cd5f5","subnet-020ec1dd449cf73a4","subnet-07fce9c6ca7181c53","subnet-086ba8ac0c970b6b2"]
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
