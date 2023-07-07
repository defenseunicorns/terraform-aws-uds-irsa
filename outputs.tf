output "role_arn" {
  description = "ARN of the IAM role"
  value       = module.irsa.iam_role_arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = module.irsa.iam_role_name
}
