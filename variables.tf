
variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket that needs IRSA applied"
}

variable "bucket_id" {
  type        = string
  description = "Name of the S3 bucket"
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

// TODO: Evaluate whether we need this to be a variable
variable "policy_name_suffix" {
  description = "IAM Policy name suffix"
  type        = string
  default     = "irsa-policy"
}