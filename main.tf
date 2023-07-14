locals {
  irsa_role_name       = try(coalesce(var.irsa_iam_role_name, format("%s-%s-%s", var.name, trim(var.kubernetes_service_account, "-*"), "irsa")), null)
}

module "irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  # renovate: datasource=github-tags depName=terraform-aws-modules/terraform-aws-iam
  version                       = "5.27.0"
  create_role                   = true
  role_name                     = local.irsa_role_name
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  force_detach_policies         = var.force_detach_policies
  role_description              = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."
  role_policy_arns               = var.role_policy_arns

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = [format("%s:%s", var.kubernetes_namespace, var.kubernetes_service_account)]
    }
  } 
  tags                          = var.tags
}
