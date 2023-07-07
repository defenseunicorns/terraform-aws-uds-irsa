module "irsa" {
  source = "../.."

  name = var.name

  policy_arns = [
    aws_iam_policy.external_dns.arn,
    aws_iam_policy.s3_policy.arn
  ]

  provider_url = var.provider_url

  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
}

resource "random_id" "unique_id" {
  byte_length = 4
}

resource "aws_iam_policy" "s3_policy" {
  name        = "S3AccessPolicy-${random_id.unique_id.hex}"
  path        = "/"
  description = "Policy for S3 access."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::dummy-bucket"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:*Object"]
        Resource = ["arn:aws:s3:::dummy-bucket/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = ["arn:aws:kms:us-west-2:123456789012:key/dummy-key"]
      }
    ]
  })
}


resource "aws_iam_policy" "external_dns" {
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
            "arn:aws:route53:::hostedzone/*"
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
