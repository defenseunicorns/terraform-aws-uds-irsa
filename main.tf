locals {
  irsa_role_name = try(coalesce(var.irsa_iam_role_name, format("%s-%s-%s", var.name, trim(var.kubernetes_service_account, "-*"), "irsa")), null)
#TODO: grab Lucas's changes for merging `var.kubernetes_service_account` and `var.kubernetes_namespace` into a single list with `var.oidc_fully_qualified_subjects`
}


module "irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # renovate: datasource=github-tags depName=terraform-aws-modules/terraform-aws-iam
  version                       = "5.27.0"
  create_role                   = true
  role_name                     = local.irsa_role_name
  provider_url                  = var.provider_url
  role_policy_arns              = length(var.policy_arns) > 0 ? var.policy_arns : []
  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  tags                          = var.tags
  force_detach_policies         = var.force_detach_policies
  role_description              = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."
}