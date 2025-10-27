terraform {
  required_version = ">= 0.13"
  required_providers {
    gdp-middleware-helper = {
      source  = IBM/gdp-middleware-helper"
      version = "0.0.1"
    }

    guardium-data-protection = {
      source  = IBM/guardium-data-protection"
      version = "0.0.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
