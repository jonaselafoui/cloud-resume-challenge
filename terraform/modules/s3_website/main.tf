resource "aws_s3_bucket" "jonas-ma" {
  bucket = "jonas-ma"

  tags = {
    Name = "Jonas Personal Website"
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

  block_public_policy     = false
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
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.jonas-ma.arn}/*"
      }
    ]
  })
}