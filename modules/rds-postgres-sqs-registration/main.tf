locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name = format("%s-%s-%s", var.aws_region, var.log_group, var.aws_account_id)
  udc_name_safe = replace(local.udc_name, "/", "-")

  # Generate the CSV content from the template
  udc_csv = templatefile("${path.module}/templates/rdsPostgresSQS.tpl", {
    udc_name        = local.udc_name_safe
    credential_name = var.udc_aws_credential
    aws_region      = var.aws_region
    aws_log_group   = var.log_group
    aws_account_id  = var.aws_account_id
    start_position  = var.csv_start_position
    interval        = var.csv_interval
    event_filter    = var.csv_event_filter
    queue_name      = module.cloudwatch_to_sqs.sqs_queue_name
    description     = "GDP AWS RDS Postgres connector for ${var.postgres_rds_cluster_identifier}"
    codec_pattern   = var.codec_pattern
    cluster_name    = var.postgres_rds_cluster_identifier
  })
}

module "cloudwatch_to_sqs" {
  source = "IBM/common/guardium//modules/aws-cloudwatch-to-sqs"
  datastore_type    = "rds_postgres"
  name_prefix       = var.postgres_rds_cluster_identifier
  lambda_source_file = "${path.cwd}/files/postgres-lambda-function.py"
  log_group         = var.log_group
  handler = "postgres-lambda-function.lambda_handler"
}

module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0  # Skip creation when disabled

  udc_name               = local.udc_name_safe
  udc_csv_parsed         = local.udc_csv
  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_ssh_username       = var.gdp_ssh_username
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_mu_host            = var.gdp_mu_host
}
