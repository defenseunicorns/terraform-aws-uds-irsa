# IRSA

Seperate IRSA module as a part of UDS Terraform for AWS


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.25.0 |
| <a name="module_irsa_policy"></a> [irsa\_policy](#module\_irsa\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.18.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_iam_policy_document.irsa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | ARN of the OIDC provider for the EKS cluster | `string` | n/a | yes |
| <a name="input_irsa_iam_permissions_boundary_arn"></a> [irsa\_iam\_permissions\_boundary\_arn](#input\_irsa\_iam\_permissions\_boundary\_arn) | IAM permissions boundary ARN for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_name"></a> [irsa\_iam\_role\_name](#input\_irsa\_iam\_role\_name) | IAM role name for IRSA | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used to encrypt and decrypt objects in S3 bucket | `any` | n/a | yes |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace for IRSA | `string` | `"default"` | no |
| <a name="input_kubernetes_service_account"></a> [kubernetes\_service\_account](#input\_kubernetes\_service\_account) | Kubernetes service account for IRSA | `string` | `"default"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for all resources that use a randomized suffix | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_role_arn"></a> [irsa\_role\_arn](#output\_irsa\_role\_arn) | ARN of the IRSA Role |
<!-- END_TF_DOCS -->
