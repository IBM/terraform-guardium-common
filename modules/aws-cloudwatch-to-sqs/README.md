# AWS CloudWatch to SQS Module

This Terraform module creates an infrastructure pipeline that forwards AWS CloudWatch logs to an Amazon SQS queue. It's designed to be a reusable component for Guardium Data Protection's audit collection architecture.

## Overview

The module sets up:

1. An SQS queue to receive log events
2. A Lambda function that polls CloudWatch logs and forwards them to the SQS queue
3. A CloudWatch Event Rule that triggers the Lambda function on a schedule
4. All necessary IAM roles and permissions

This architecture enables Guardium to consume AWS service logs from CloudWatch via SQS, providing a reliable and scalable way to monitor AWS services.

## Usage

```hcl
module "cloudwatch_to_sqs" {
  source = "../../modules/common/aws-cloudwatch-to-sqs"

  name_prefix      = "my-service"
  datastore_type   = "dynamodb"
  lambda_source_file = "${path.module}/files/lambda.py"
  aws_log_group    = "/aws/cloudtrail/my-trail"
  
  tags = {
    Environment = "Production"
    Service     = "Guardium"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming resources | `string` | n/a | yes |
| datastore_type | Type of datastore (e.g., dynamodb, documentdb) - used as suffix for resource names | `string` | n/a | yes |
| lambda_source_file | Path to the Lambda function source code | `string` | n/a | yes |
| aws_log_group | CloudWatch log group to monitor | `string` | n/a | yes |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| sqs_queue_url | URL of the SQS queue |
| sqs_queue_arn | ARN of the SQS queue |
| lambda_function_name | Name of the Lambda function |
| lambda_function_arn | ARN of the Lambda function |

## Lambda Function

The module expects a Python Lambda function that:

1. Polls CloudWatch logs from the specified log group
2. Processes the log events
3. Forwards them to the SQS queue

The Lambda function should have a handler named `lambda_handler` and will receive two environment variables:
- `GROUP_NAME`: The CloudWatch log group to monitor
- `QUEUE_NAME`: The URL of the SQS queue

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   CloudWatch    │     │     Lambda      │     │      SQS        │
│    Log Group    │────▶│    Function     │────▶│     Queue       │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       ▲                        │
        │                       │                        │
        │                       │                        │
        │                ┌─────────────────┐             │
        │                │                 │             │
        └───────────────▶│   CloudWatch    │             │
                         │  Event Rule     │             │
                         │  (2 min rate)   │             │
                         └─────────────────┘             │
                                                         │
                                                         ▼
                                                ┌─────────────────┐
                                                │                 │
                                                │    Guardium     │
                                                │    Connector    │
                                                │                 │
                                                └─────────────────┘
```

## IAM Permissions

The module creates IAM roles with the following permissions:

1. Lambda execution role with:
   - Full access to SQS
   - Full access to CloudWatch Logs
   - Full access to CloudWatch Events

These broad permissions are used for simplicity but could be restricted further for production environments.

## Scheduling

By default, the Lambda function runs every 2 minutes to check for new log events. This interval is hardcoded in the CloudWatch Event Rule.

## Integration with Guardium

This module is typically used as part of a larger Guardium Data Protection setup:

1. AWS services write logs to CloudWatch
2. This module forwards logs to SQS
3. A Guardium Universal Connector reads from the SQS queue
4. Guardium processes and analyzes the log data

## Limitations and Considerations

- The module uses full access policies which may be too permissive for production
- The 2-minute polling interval is fixed and may need adjustment for high-volume environments
- There's no dead-letter queue configured for the SQS queue
- The Lambda function should implement proper error handling and pagination

## Requirements

- Terraform >= 0.13
- AWS provider
- Archive provider (for Lambda function packaging)