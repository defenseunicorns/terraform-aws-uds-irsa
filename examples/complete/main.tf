module "irsa" {
  source = "../.."

  name                       = var.name
  kubernetes_namespace       = var.kubernetes_namespace
  kubernetes_service_account = "${var.kubernetes_service_account}-${random_id.unique_id.hex}" #added in random hex to allow for parallel applies (otherwise terraform would error as role names need to be unique)
  oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_arn}"
  irsa_iam_role_name         = var.irsa_iam_role_name

  role_policy_arns = tomap({
    "external-dns" = aws_iam_policy.external_dns_policy.arn,
    "loki"         = aws_iam_policy.loki_policy.arn,
    "velero"       = aws_iam_policy.velero_policy.arn
  })

}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "random_id" "unique_id" {
  byte_length = 4
}

resource "aws_iam_policy" "loki_policy" {
  name        = "LokiPolicy-${random_id.unique_id.hex}"
  path        = "/"
  description = "Policy for S3 access."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:*Object"]
        Resource = ["arn:aws:s3:::*"]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = ["arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"]
      }
    ]
  })
}
resource "aws_iam_policy" "external_dns_policy" {
  name        = "AllowExternalDNSUpdates-${random_id.unique_id.hex}"
  path        = "/"
  description = "Policy for external-dns to create records in route53 hosted zones."
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "route53:ChangeResourceRecordSets"
          ]
          Resource = [
            "arn:${data.aws_partition.current.partition}:route53:::hostedzone/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResource"
          ]
          Resource = [
            "*"
          ]
        }
      ]
  })
}

resource "aws_iam_policy" "velero_policy" {
  name        = "VeleroPolicy-${random_id.unique_id.hex}"
  path        = "/"
  description = "Policy to give Velero necessary permissions for cluster backups."

  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots",
            "ec2:CreateTags",
            "ec2:CreateVolume",
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot"
          ]
          Resource = [
            "*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:PutObject",
            "s3:AbortMultipartUpload",
            "s3:ListMultipartUploadParts"
          ]
          Resource = [
            "arn:aws:s3:::*"
          ]
        },
        {
          Effect = "Allow",
          Action = [
            "s3:ListBucket"
          ],
          Resource = [
            "arn:aws:s3:::*"
          ]
        }
      ]
  })
}