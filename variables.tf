variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN of the OIDC provider for the EKS cluster"
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = ""
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary_arn" {
  description = "IAM permissions boundary ARN for IRSA roles"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt and decrypt objects in S3 bucket"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for IRSA"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account for IRSA"
  type        = string
  default     = "default"
}

variable "name_prefix" {
  description = "Name prefix for all resources that use a randomized suffix"
  type        = string
  validation {
    condition     = length(var.name_prefix) <= 37
    error_message = "Name Prefix may not be longer than 37 characters."
  }
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
