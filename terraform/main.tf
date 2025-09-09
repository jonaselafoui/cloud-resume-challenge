resource "aws_s3_bucket" "jonas-ma" {
  bucket = "jonas-ma"

  tags = {
    Name        = "Jonas Personal Website"
  }
}

resource "aws_s3_bucket_website_configuration" "jonas-ma" {
  bucket = aws_s3_bucket.jonas-ma.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "jonas-ma-public-access" {
  bucket = aws_s3_bucket.jonas-ma.id

  block_public_policy = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "jonas-ma-public_read" {
  bucket = aws_s3_bucket.jonas-ma.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
            "s3:GetObject"
        ]
        Resource  = "${aws_s3_bucket.jonas-ma.arn}/*"
      }
    ]
  })
}

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
  name   = "codebuild-static-site-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject", "s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.jonas-ma.arn,
          "${aws_s3_bucket.jonas-ma.arn}/*"
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
  name          = "static-site-build"
  description   = "Copies static files from GitHub to the S3 website bucket."
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    environment_variable {
      name  = "BUCKET_NAME"
      value = aws_s3_bucket.jonas-ma.bucket
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
    buildspec = <<EOF
version: 0.2
phases:
  build:
    commands:
      - echo "Deploying static site to S3..."
      - cd website
      - aws s3 sync . s3://${aws_s3_bucket.jonas-ma.bucket} --delete
artifacts:
  files: []
EOF
  }
}

resource "aws_iam_role" "pipeline_role" {
  name = "codepipeline-static-site-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "pipeline_policy" {
  name   = "codepipeline-static-site-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      /* Permission to start the CodeBuild project */
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.site_build.arn
      },
      /* S3 access for the artifact store (you can use a separate bucket if you prefer) */
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.jonas-ma.arn,
          "${aws_s3_bucket.jonas-ma.arn}/*"
        ]
      },
      /* Read the secret so CodeBuild can get the GitHub token */
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:eu-central-1:535363408495:secret:github-token-QZjeoQ"
      },
      /* CloudWatch Logs for the pipeline itself */
      {
        Effect = "Allow"
        Action = ["logs:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_attach" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = aws_iam_policy.pipeline_policy.arn
}

# Pull the secret value so we can pass the raw token to the Source action
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "github-token"
}

resource "aws_codepipeline" "site_pipeline" {
  name     = "static-site-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.jonas-ma.bucket   # you can use a dedicated artifact bucket instead
  }

  /* ---------- Stage 1: Source (GitHub) ---------- */
  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "jonaselafoui"
        Repo       = "cloud-resume-challenge"
        Branch     = "main"
        OAuthToken = data.aws_secretsmanager_secret_version.github_token.secret_string
      }
    }
  }

  /* ---------- Stage 2: Build (CodeBuild) ---------- */
  stage {
    name = "Build"

    action {
      name            = "CodeBuild"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.site_build.name
      }
    }
  }

  # Optional: add a manual approval stage, a deploy stage, etc.
}