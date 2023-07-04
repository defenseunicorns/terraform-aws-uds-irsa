locals {
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.25.0"

  role_name        = try(coalesce(var.irsa_iam_role_name, format("%s-%s-%s", var.name_prefix, trim(var.kubernetes_service_account, "-*"), "irsa")), null)
  role_description = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = [format("%s:%s", var.kubernetes_namespace, var.kubernetes_service_account)]
    }
  }

  role_path                     = var.irsa_iam_role_path
  force_detach_policies         = true
  role_permissions_boundary_arn = var.irsa_iam_permissions_boundary_arn

  tags = var.tags
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = var.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Principal = {
          AWS = module.irsa.iam_role_arn
        }
        Resource = [
          local.bucket_arn,
          "${local.bucket_arn}/*"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.bucket_arn]
  }
  statement {
    actions   = ["s3:*Object"]
    resources = ["${local.bucket_arn}/*"]
  }
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [var.kms_key_arn]
  }
}

module "irsa_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.18.0"

  description = "IAM Policy for IRSA"
  name_prefix = "${var.name_prefix}-irsa-policy"
  policy      = data.aws_iam_policy_document.irsa_policy.json
}

resource "aws_iam_role_policy_attachment" "irsa" {
  policy_arn = module.irsa_policy.arn
  role       = module.irsa.iam_role_name
}