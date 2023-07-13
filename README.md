# IAM Role for Service Accounts (IRSA) Module

This repository contains Terraform configuration files that create an IAM role that can be used by applications running in a Kubernetes cluster to have the necessary permissions to interact with AWS services.

## Examples

To view examples for how you can leverage this IRSA Module, please see the [examples](https://github.com/defenseunicorns/terraform-aws-uds-irsa/tree/main/examples) directory.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.27.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | n/a | `bool` | `true` | no |
| <a name="input_irsa_iam_role_name"></a> [irsa\_iam\_role\_name](#input\_irsa\_iam\_role\_name) | IAM role name for IRSA, overrides name variable for irsa module input `role_name` | `string` | `""` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Name of the namespace that the service account exists in. Used to generate fully qualified subject for the service account. | `string` | n/a | yes |
| <a name="input_kubernetes_service_account"></a> [kubernetes\_service\_account](#input\_kubernetes\_service\_account) | Name of the service account to bind to. Used to generate fully qualified subject for service account. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Cluster name, used in the name of the iam role that is created | `string` | `"irsa-role"` | no |
| <a name="input_oidc_fully_qualified_subjects"></a> [oidc\_fully\_qualified\_subjects](#input\_oidc\_fully\_qualified\_subjects) | The fully qualified OIDC subjects to be added to the role policy | `list(string)` | `[]` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of IAM policy ARNs to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_provider_url"></a> [provider\_url](#input\_provider\_url) | OIDC provider URL | `string` | n/a | yes |
| <a name="input_role_permissions_boundary_arn"></a> [role\_permissions\_boundary\_arn](#input\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for IAM role | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |