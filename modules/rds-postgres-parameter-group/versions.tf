terraform {
  required_version = ">= 0.13"
  required_providers {
    gdp-middleware-helper = {
      source  = "na.artifactory.swg-devops.com/ibm/gdp-middleware-helper"
      version = "0.0.3"
    }

    guardium-data-protection = {
      source  = "na.artifactory.swg-devops.com/ibm/guardium-data-protection"
      version = "0.0.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}