variable "role_policy_arns" {
  description = "ARNs of any policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "name" {
  type        = string
  description = "Cluster name, used in the name of the iam role that is created"
  default     = "irsa-role"
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA, overrides name variable for irsa module input `role_name`"
  default     = ""
}

variable "force_detach_policies" {
  default = true
  type    = bool
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN e.g., arn:aws:iam::<ACCOUNT-ID>:oidc-provider/<OIDC-PROVIDER>"
  type        = string
}

variable "role_permissions_boundary_arn" {
  type        = string
  description = "Permissions boundary ARN to use for IAM role"
  default     = null
}

variable "kubernetes_service_account" {
  description = "Name of the service account to bind to. Used to generate fully qualified subject for service account."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Name of the namespace that the service account exists in. Used to generate fully qualified subject for the service account."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Map of tags"
  default     = {}
}
