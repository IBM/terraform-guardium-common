#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 0.13"
  required_providers {
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = "1.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}