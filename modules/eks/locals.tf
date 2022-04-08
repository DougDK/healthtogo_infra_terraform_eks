locals {
  cluster_trust_oidc_provider = replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  aws_account_id = data.aws_caller_identity.current.account_id
}