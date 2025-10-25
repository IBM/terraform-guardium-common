terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }

    gdp-middleware-helper = {
      source  = "na.artifactory.swg-devops.com/ibm/gdp-middleware-helper"
      version = "0.0.3"
    }
  }
}
