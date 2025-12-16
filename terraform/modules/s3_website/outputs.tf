output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.jonas-ma.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.jonas-ma.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 Bucket"
  value       = aws_s3_bucket.jonas-ma.bucket_regional_domain_name
}