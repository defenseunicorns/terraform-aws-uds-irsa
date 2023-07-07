module "irsa" {
  source = "../.."

  name = var.name

  policy_arns = [
    aws_iam_policy.external_dns_policy.arn,
    aws_iam_policy.loki_policy.arn,
    aws_iam_policy.velero_policy.arn
  ]

  provider_url = var.provider_url

  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
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
        Resource = ["arn:${data.aws_partition.current.partition}:s3:::dummy-bucket"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:*Object"]
        Resource = ["arn:${data.aws_partition.current.partition}:s3:::dummy-bucket/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = ["arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/dummy-key"]
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
            "arn:${data.aws_partition.current.partition}:s3:::dummy-bucket/*"
          ]
        },
        {
          Effect = "Allow",
          Action = [
            "s3:ListBucket"
          ],
          Resource = [
            "arn:${data.aws_partition.current.partition}:s3:::dummy-bucket/*"
          ]
        }
      ]
  })
}
