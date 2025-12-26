resource "aws_dynamodb_table" "visitorcounter_db" {
  name             = "visitorcounter_db"
  hash_key         = "visitorcounter_id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "visitorcounter_id"
    type = "N"
  }

  attribute {
    name = "number_of_visitors"
    type = "N"
  }
}