# Guardium Terraform Common Modules

Terraform modules providing shared utilities and resources for integrating AWS data stores with IBM Guardium Data Protection.

## Scope

This repository contains common Terraform modules that are used as building blocks by the main [Guardium Terraform](https://IBM/guardium-terraform) repository. These modules provide reusable components for AWS resource configuration, CloudWatch integration, and database parameter management.

## Used By

This common module is a dependency for the following official Guardium Terraform Registry modules:

- **[IBM Guardium Datastore Vulnerability Assessment Module](https://registry.terraform.io/modules/IBM/datastore-va/guardium/latest)** - Configures databases for vulnerability assessment and integrates with Guardium Data Protection
- **[IBM Guardium Datastore Audit Module](https://registry.terraform.io/modules/IBM/datastore-audit/guardium/latest)** - Configures audit logging for datastores and integrates with Guardium Universal Connector
- **[IBM Guardium Data Protection Module](https://registry.terraform.io/modules/IBM/gdp/guardium/latest)** - Core Guardium Data Protection integration module

## Usage

These modules are designed to be used as dependencies by other Guardium Terraform modules. They provide shared functionality for:

- AWS account configuration and information
- CloudWatch to SQS integration for log streaming
- AWS Secrets Manager configuration
- RDS parameter group management for PostgreSQL and MariaDB
- Database registration with Guardium Universal Connector

### AWS Configuration

Retrieves AWS account information and provides common data sources.

```hcl
module "aws_configuration" {
  source = "IBM/terraform-guardium-common//modules/aws-configuration"
}
```

### AWS CloudWatch to SQS

Sets up CloudWatch Logs subscription filters to stream logs to SQS queues for processing by Guardium.

```hcl
module "cloudwatch_to_sqs" {
  source = "IBM/terraform-guardium-common//modules/aws-cloudwatch-to-sqs"

  log_group_name = "/aws/rds/instance/my-database/postgresql"
  sqs_queue_arn  = "arn:aws:sqs:us-east-1:123456789012:guardium-logs"
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### RDS PostgreSQL Parameter Group

Creates and manages RDS parameter groups for PostgreSQL with audit logging configurations.

```hcl
module "postgres_parameter_group" {
  source = "IBM/terraform-guardium-common//modules/rds-postgres-parameter-group"

  name_prefix = "guardium-postgres"
  family      = "postgres14"
  
  parameters = {
    log_statement           = "all"
    log_connections         = "1"
    log_disconnections      = "1"
    pgaudit.log             = "all"
  }
}
```

### RDS MariaDB/MySQL Parameter Group

Creates and manages RDS option groups for MariaDB and MySQL with audit logging configurations using the MariaDB Audit Plugin.

```hcl
module "mariadb_mysql_parameter_group" {
  source = "IBM/terraform-guardium-common//modules/rds-mariadb-mysql-parameter-group"

  db_engine              = "mariadb" # or "mysql"
  rds_cluster_identifier = "my-mariadb-cluster"
  db_major_version       = "10.6" # or "5.7" for MySQL
  
  # Optional audit configuration
  audit_events           = "CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL"
  audit_excl_users       = "rdsadmin"
  force_failover         = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### RDS PostgreSQL CloudWatch Registration

Registers RDS PostgreSQL instances with Guardium Universal Connector via CloudWatch.

```hcl
module "postgres_cloudwatch_registration" {
  source = "IBM/terraform-guardium-common//modules/rds-postgres-cloudwatch-registration"

  db_instance_identifier = "my-postgres-db"
  guardium_host         = "guardium.example.com"
  guardium_port         = 8443
}
```

### RDS PostgreSQL SQS Registration

Registers RDS PostgreSQL instances with Guardium Universal Connector via SQS.

```hcl
module "postgres_sqs_registration" {
  source = "IBM/terraform-guardium-common//modules/rds-postgres-sqs-registration"

  db_instance_identifier = "my-postgres-db"
  sqs_queue_url         = "https://sqs.us-east-1.amazonaws.com/123456789012/guardium-logs"
  guardium_host         = "guardium.example.com"
}
```

### RDS MariaDB/MySQL CloudWatch Registration

Registers RDS MariaDB and MySQL instances with Guardium Universal Connector via CloudWatch.

```hcl
module "mariadb_mysql_cloudwatch_registration" {
  source = "IBM/terraform-guardium-common//modules/rds-mariadb-mysql-cloudwatch-registration"

  # Required AWS variables
  db_engine              = "mariadb" # or "mysql"
  rds_cluster_identifier = "my-mariadb-cluster"
  aws_account_id         = "123456789012"
  aws_region             = "us-east-1"
  log_group              = "/aws/rds/cluster/my-mariadb-cluster/audit"
  
  # Required Guardium credentials
  udc_aws_credential     = "aws-credential-name"
  gdp_client_id          = "your-client-id"
  gdp_client_secret      = "your-client-secret"
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "guardium-user"
  gdp_password           = "guardium-password"
  gdp_ssh_username       = "guardium-ssh-user"
  gdp_ssh_privatekeypath = "/path/to/private/key"
  gdp_mu_host            = "managed-unit-1,managed-unit-2"
  
  # Optional configuration
  enable_universal_connector = true
  csv_start_position        = "end"
  csv_interval              = "5"
}
```

## Modules

### aws-configuration
Provides AWS account information and common data sources used by other modules.

**Outputs:**
- `account_id` - AWS account ID
- `region` - AWS region
- `caller_identity` - AWS caller identity information

### aws-cloudwatch-to-sqs
Creates CloudWatch Logs subscription filters to stream logs to SQS queues.

**Inputs:**
- `log_group_name` - CloudWatch log group name
- `sqs_queue_arn` - Target SQS queue ARN
- `filter_pattern` - Optional log filter pattern

**Outputs:**
- `subscription_filter_name` - Name of the created subscription filter

### aws-secrets-manager-config
Manages AWS Secrets Manager configurations for storing database credentials.

**Outputs:**
- `secret_arn` - ARN of the created secret

### rds-postgres-parameter-group
Creates RDS parameter groups for PostgreSQL with audit logging enabled.

**Inputs:**
- `name_prefix` - Prefix for parameter group name
- `family` - PostgreSQL family (e.g., postgres14)
- `parameters` - Map of parameter names and values

**Outputs:**
- `parameter_group_name` - Name of the created parameter group
- `parameter_group_arn` - ARN of the parameter group

### rds-mariadb-mysql-parameter-group
Creates RDS option groups for MariaDB and MySQL with the MariaDB Audit Plugin enabled.

**Inputs:**
- `db_engine` (required) - Database engine type (mysql or mariadb)
- `rds_cluster_identifier` (required) - RDS cluster identifier to be monitored
- `db_major_version` (required) - Major version of the database (e.g., '5.7' for MySQL, '10.6' for MariaDB)
- `aws_region` - AWS region (default: us-east-1)
- `tags` - Map of tags to apply to resources (default: {})
- `audit_events` - Events to audit (default: CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL)
- `audit_file_rotations` - Number of audit file rotations to keep (default: "10")
- `audit_file_rotate_size` - Size in bytes at which to rotate the audit log file (default: "1000000")
- `force_failover` - Whether to failover the database instance (default: true)
- `audit_incl_users` - Comma-separated list of users to include in audit logs (default: "")
- `audit_excl_users` - Comma-separated list of users to exclude from audit logs (default: "rdsadmin")
- `audit_query_log_limit` - Maximum query length to log in bytes (default: "1024")

**Outputs:**
- `parameter_group_name` - Name of the RDS parameter group
- `option_group_name` - Name of the RDS option group with audit plugin

### rds-postgres-cloudwatch-registration
Registers PostgreSQL RDS instances with Guardium via CloudWatch.

**Inputs:**
- `db_instance_identifier` - RDS instance identifier
- `guardium_host` - Guardium host address
- `guardium_port` - Guardium port (default: 8443)

### rds-postgres-sqs-registration
Registers PostgreSQL RDS instances with Guardium via SQS.

**Inputs:**
- `db_instance_identifier` - RDS instance identifier
- `sqs_queue_url` - SQS queue URL
- `guardium_host` - Guardium host address

### rds-mariadb-mysql-cloudwatch-registration
Registers MariaDB and MySQL RDS instances with Guardium via CloudWatch.

**Inputs:**
- `db_engine` (required) - Database engine type (mysql or mariadb)
- `rds_cluster_identifier` (required) - RDS cluster identifier to be monitored
- `aws_account_id` (required) - AWS account ID, used to generate the universal connector name
- `log_group` (required) - Name of the CloudWatch log group
- `udc_aws_credential` (required) - Name of AWS credential defined in Guardium
- `gdp_client_id` (required) - Client ID used when running grdapi register_oauth_client
- `gdp_client_secret` (required) - Client secret from output of grdapi register_oauth_client
- `gdp_server` (required) - Hostname/IP address of Guardium Central Manager
- `gdp_username` (required) - Username of Guardium Web UI user
- `gdp_password` (required) - Password of Guardium Web UI user
- `gdp_ssh_username` (required) - Guardium OS user with SSH access
- `gdp_ssh_privatekeypath` (required) - Private SSH key to connect to Guardium OS
- `gdp_mu_host` (required) - Comma separated list of Guardium Managed Units to deploy profile
- `aws_region` - AWS region (default: us-east-1)
- `gdp_port` - Port of Guardium Central Manager (default: "8443")
- `udc_name` - Name for universal connector (default: "rds-gdp")
- `enable_universal_connector` - Whether to enable the universal connector module (default: true)
- `csv_start_position` - Start position for UDC (default: "end")
- `csv_interval` - Polling interval for UDC (default: "5")
- `csv_event_filter` - UDC Event filters (default: "")
- `codec_pattern` - Codec pattern for RDS database (default: "plain")
- `cloudwatch_endpoint` - Custom endpoint URL for AWS CloudWatch (default: "")
- `use_aws_bundled_ca` - Whether to use the AWS bundled CA certificates (default: true)

## Prerequisites

- Terraform v1.9.8 or later
- AWS CLI configured with appropriate credentials
- Access to IBM Guardium Data Protection instance
- AWS permissions for:
  - CloudWatch Logs
  - SQS
  - RDS
  - IAM
  - Secrets Manager

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For issues and questions:
- Create an issue in this repository
- Contact the maintainers listed in [MAINTAINERS.md](MAINTAINERS.md)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
```

## Authors

Module is maintained by IBM with help from [these awesome contributors](https://github.com/IBM/terraform-guardium-datastore-va/graphs/contributors).
