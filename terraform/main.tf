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