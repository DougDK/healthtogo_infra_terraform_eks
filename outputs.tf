output "aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = data.aws_region.current.name
}

output "workspace" {
  value = local.env
}

