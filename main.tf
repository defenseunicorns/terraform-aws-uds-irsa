resource "random_id" "unique_id" {
  byte_length = 4
}

module "irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.27.0"
  create_role                   = true
  role_name                     = "${var.name}-${random_id.unique_id.hex}"
  provider_url                  = var.provider_url
  role_policy_arns              = length(var.policy_arns) > 0 ? var.policy_arns : []
  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  tags                          = var.tags
}
