resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-static-site-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "codebuild-static-site-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:DeleteObject", "s3:GetObject", "s3:ListBucket"]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:eu-central-1:535363408495:secret:github-token-QZjeoQ"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_codebuild_project" "site_build" {
  name         = "static-site-build"
  description  = "Copies static files from GitHub to the S3 website bucket."
  service_role = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
    environment_variable {
      name  = "BUCKET_NAME"
      value = var.bucket_name
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/jonaselafoui/cloud-resume-challenge.git"
    git_clone_depth = 1

    /* Authenticate with the token stored in Secrets Manager */
    auth {
      type     = "OAUTH"
      resource = "arn:aws:secretsmanager:eu-central-1:535363408495:secret:github-token-QZjeoQ"
    }

    /* Inline buildspec – you could also point to a buildspec.yml in the repo */
    buildspec = file("${path.module}/buildspec.yml")
  }
}