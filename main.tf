terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "029DA-DevOps24"
    
    workspaces {
        prefix = "network-"
    }
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

provider "aws" {}

module "billing_alert" {
    source = "binbashar/cost-billing-alarm/aws"
    create_sns_topic = true
    aws_env = "029DO-FA24"
    monthly_billing_threshold = 5
    currency = "USD"
}
output "sns_topic_arn" {
    value = "${module.billing_alert.sns_topic_arns}"
}
module "iam" {
    source = "./modules/iam"
    groups = {
        system_admins = ["admin1", "admin2"]
        database_admins = ["dbadmin1", "dbadmin2"]
        read_only = ["readonly1", "readonly2"]
    }
    minimum_password_length = 8
    password_reuse_prevention = 3
    require_lowercase_characters = true
}