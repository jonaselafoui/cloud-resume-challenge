output "visitorcounter_db_arn" {
    description = "ARN of the visitorcounter_db"
    value       = aws_dynamodb_table.visitorcounter_db.arn
}

output "visitorcounter_db_name" {
    description = "Name of the visitorcounter_db"
    value       = aws_dynamodb_table.visitorcounter_db.name
}