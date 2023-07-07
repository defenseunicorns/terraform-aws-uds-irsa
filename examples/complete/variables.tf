variable "provider_url" {
  type        = string
  description = "OIDC provider URL"
  default     = "oidc.eks.us-west-2.amazonaws.com/id/dummy-oidc-provider"
}

variable "name" {
  type        = string
  description = "IAM role name"
  default     = "irsa_role"
}

variable "oidc_fully_qualified_subjects" {
  type        = list(string)
  description = "The fully qualified OIDC subjects to be added to the role policy"
  default     = []
}
