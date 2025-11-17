#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# RDS MariaDB/MySQL Parameter Group Module Outputs

output "parameter_group_name" {
  description = "Name of the RDS parameter group"
  value       = aws_db_parameter_group.db_param_group.name
}

output "option_group_name" {
  description = "Name of the RDS option group with audit plugin"
  value       = aws_db_option_group.audit.name
}