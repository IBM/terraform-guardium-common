output "sqs_queue_url" {
  value       = aws_sqs_queue.guardium_q.url
  description = "URL of the SQS queue"
}

output "sqs_queue_name" {
  value       = aws_sqs_queue.guardium_q.name
  description = "Name of the SQS queue"
}

output "sqs_queue_arn" {
  value       = aws_sqs_queue.guardium_q.arn
  description = "ARN of the SQS queue"
}

output "lambda_function_name" {
  value       = aws_lambda_function.guardium.function_name
  description = "Name of the Lambda function"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.guardium.arn
  description = "ARN of the Lambda function"
}