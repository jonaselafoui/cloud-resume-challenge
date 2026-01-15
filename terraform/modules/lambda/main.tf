data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/code.zip"
}

resource "aws_iam_role" "counter-lambda-role" {
  name = "counter-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.counter-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ddb_update" {
  name = "counter-ddb-update"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:UpdateItem"],
      Resource = var.table_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.counter-lambda-role.name
  policy_arn = aws_iam_policy.ddb_update.arn
}

resource "aws_lambda_function" "lambda-counter" {
  function_name = "lambda-counter"
  role          = aws_iam_role.counter-lambda-role.arn

  runtime = "python3.12"
  handler = "app.lambda_handler"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      COUNTER_ID = var.counter_id
    }
  }
}
