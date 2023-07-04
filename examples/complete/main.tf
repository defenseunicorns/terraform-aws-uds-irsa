output "irsa_role_arn" {
  description = "ARN of the IRSA Role"
  value       = module.irsa.irsa_role_arn
}

module "irsa" {
  source = "../.."

  bucket_name           = var.bucket_name
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  irsa_iam_role_name    = var.irsa_iam_role_name
  kms_key_arn           = var.kms_key_arn
  name_prefix           = var.name_prefix
}
