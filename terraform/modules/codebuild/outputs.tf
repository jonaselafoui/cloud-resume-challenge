output "codebuild_arn" {
    description = "The ARN of the codebuild"
    value       = aws_codebuild_project.site_build.arn
}

output "codebuild_name" {
    description = "Name of Codebuild"
    value       = aws_codebuild_project.site_build.name
}