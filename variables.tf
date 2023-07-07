variable "oidc_fully_qualified_subjects" {
  type        = list(string)
  description = "The fully qualified OIDC subjects to be added to the role policy"
  default     = []
}

variable "policy_arns" {
  type        = list(string)
  description = "List of IAM policy ARNs to attach to the IAM role"
}

variable "provider_url" {
  type        = string
  description = "OIDC provider URL"
}

variable "name" {
  type        = string
  description = "IAM role name"
  default     = "irsa_role"
}

variable "role_permissions_boundary_arn" {
  type        = string
  description = "Permissions boundary ARN to use for IAM role"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of tags"
  default     = {}
}
