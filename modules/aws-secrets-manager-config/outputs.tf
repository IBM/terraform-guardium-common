# AWS Secrets Manager Configuration Module - Outputs

output "aws_secrets_manager_config_id" {
  description = "ID of the AWS Secrets Manager configuration in Guardium"
  value       = local.aws_secrets_manager_config_id
}

output "aws_secrets_manager_config_name" {
  description = "Name of the AWS Secrets Manager configuration in Guardium"
  value       = local.aws_secrets_manager_config_name
}

output "aws_secrets_manager_config_auth_type" {
  description = "Authentication type of the AWS Secrets Manager configuration in Guardium"
  value       = local.aws_secrets_manager_config_auth_type
}