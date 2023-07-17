variable "name" {
  type        = string
  description = "Cluster name, used in the name of the iam role that is created"
  default     = "cluster-name"
}

variable "kubernetes_namespace" {
  type    = string
  default = "some-namespace"
}

variable "kubernetes_service_account" {
  type    = string
  default = "service-account"
}

variable "irsa_iam_role_name" {
  type    = string
  default = ""
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  default     = ""
}