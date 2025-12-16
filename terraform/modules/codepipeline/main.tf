
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
  name = "codepipeline-static-site-policy"
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
        Resource = var.codebuild_arn
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
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      },
      /* Read the secret so CodeBuild can get the GitHub token */
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:eu-central-1:535363408495:secret:github-token-QZjeoQ"
      },
      /* CloudWatch Logs for the pipeline itself */
      {
        Effect   = "Allow"
        Action   = ["logs:*"]
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
    location = var.bucket_name
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
        ProjectName = var.codebuild_name
      }
    }
  }

  # Optional: add a manual approval stage, a deploy stage, etc.
}