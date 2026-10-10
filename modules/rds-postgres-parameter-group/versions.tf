terraform {
  required_version = ">= 0.13"
  required_providers {
    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = "1.3.0"
    }

    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = "= 1.4.9"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
