
output "irsa_role" {
  description = "ARN of the IRSA Role"
  value       = module.irsa.iam_role_arn
}
