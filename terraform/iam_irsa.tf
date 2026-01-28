module "loki_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-loki-irsa"

  role_policy_arns = {
    policy = aws_iam_policy.loki_s3.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.observability_namespace}:loki"]
    }
  }
}

resource "aws_iam_policy" "loki_s3" {
  name        = "${var.cluster_name}-loki-s3-policy"
  description = "IAM policy for Loki to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::loki-bucket",
          "arn:aws:s3:::loki-bucket/*"
        ]
      }
    ]
  })
}

module "tempo_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-tempo-irsa"

  role_policy_arns = {
    policy = aws_iam_policy.tempo_s3.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.observability_namespace}:tempo"]
    }
  }
}

resource "aws_iam_policy" "tempo_s3" {
  name        = "${var.cluster_name}-tempo-s3-policy"
  description = "IAM policy for Tempo to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::tempo-bucket",
          "arn:aws:s3:::tempo-bucket/*"
        ]
      }
    ]
  })
}

