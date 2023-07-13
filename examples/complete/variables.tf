variable "provider_url" {
  type        = string
  description = "OIDC provider URL"
  default     = "oidc.eks.us-west-2.amazonaws.com/id/dummy-oidc-provider"
}

variable "name" {
  type        = string
  description = "Cluster name, used in the name of the iam role that is created"
  default     = "cluster-name"
}

variable "oidc_fully_qualified_subjects" {
  type        = list(string)
  description = "The fully qualified OIDC subjects to be added to the role policy"
  default     = []
}

variable "kubernetes_namespace" {
  default = "some-namespace"
}

variable "kubernetes_service_account" {
  default = "service-account"
}

variable "irsa_iam_role_name" {
  default = ""
}