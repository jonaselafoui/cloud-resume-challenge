output "function_name" {
  value = aws_lambda_function.lambda-counter.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.lambda-counter.invoke_arn
}

output "function_arn" {
  value = aws_lambda_function.lambda-counter.arn
}
