resource "aws_dynamodb_table" "visitorcounter_db" {
  name             = "visitorcounter_db"
  hash_key         = "visitorcounter"
  billing_mode     = "PAY_PER_REQUEST"
  #stream_enabled   = true
  #stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "visitorcounter"
    type = "N"
  }
}