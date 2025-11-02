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

### RDS MariaDB Parameter Group

Creates and manages RDS parameter groups for MariaDB with audit logging configurations.

```hcl
module "mariadb_parameter_group" {
  source = "IBM/terraform-guardium-common//modules/rds-mariadb-parameter-group"

  name_prefix = "guardium-mariadb"
  family      = "mariadb10.6"
  
  parameters = {
    server_audit_logging    = "1"
    server_audit_events     = "CONNECT,QUERY,TABLE"
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

### RDS MariaDB CloudWatch Registration

Registers RDS MariaDB instances with Guardium Universal Connector via CloudWatch.

```hcl
module "mariadb_cloudwatch_registration" {
  source = "IBM/terraform-guardium-common//modules/rds-mariadb-cloudwatch-registration"

  db_instance_identifier = "my-mariadb-db"
  guardium_host         = "guardium.example.com"
  guardium_port         = 8443
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

### rds-mariadb-parameter-group
Creates RDS parameter groups for MariaDB with audit logging enabled.

**Inputs:**
- `name_prefix` - Prefix for parameter group name
- `family` - MariaDB family (e.g., mariadb10.6)
- `parameters` - Map of parameter names and values

**Outputs:**
- `parameter_group_name` - Name of the created parameter group
- `parameter_group_arn` - ARN of the parameter group

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

### rds-mariadb-cloudwatch-registration
Registers MariaDB RDS instances with Guardium via CloudWatch.

**Inputs:**
- `db_instance_identifier` - RDS instance identifier
- `guardium_host` - Guardium host address
- `guardium_port` - Guardium port (default: 8443)

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
