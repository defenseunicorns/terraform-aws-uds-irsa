output "irsa_role_arn" {
  description = "ARN of the IRSA Role"
  value       = module.irsa.iam_role_arn
}
