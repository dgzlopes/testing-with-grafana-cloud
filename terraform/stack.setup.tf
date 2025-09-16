terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.9.0"
    }
  }
}

// Parse .env into a map
locals {
  env = {
    for tuple in regexall("(.*?)=(.*)", file("${abspath("${path.module}/../.env")}")) :
    trim(tuple[0], " \t\n\r") => trim(tuple[1], " \t\n\r")
  }
}

# Assign local vars from env map
locals {
  stack_slug                = local.env["STACK_SLUG"]
  cloud_region              = local.env["CLOUD_REGION"]
  cloud_access_policy_token = local.env["CLOUD_ACCESS_POLICY_TOKEN"]
}

# Configure the Grafana Cloud provider
provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = local.cloud_access_policy_token
}

data "grafana_cloud_stack" "testing_stack" {
  provider = grafana.cloud
  slug     = local.stack_slug
}

resource "grafana_cloud_stack_service_account" "testing_sa" {
  provider   = grafana.cloud
  stack_slug = local.stack_slug

  name        = "${local.stack_slug}-terraform-sa"
  role        = "Admin"
  is_disabled = false
}

resource "grafana_cloud_stack_service_account_token" "testing_sa_token" {
  provider   = grafana.cloud
  stack_slug = local.stack_slug

  name               = "${local.stack_slug}-terraform-sa-token"
  service_account_id = grafana_cloud_stack_service_account.testing_sa.id
}

# Install GCk6 app. If the app is already installed, this step is a no-op.
resource "grafana_k6_installation" "k6_installation" {
  provider = grafana.cloud

  cloud_access_policy_token = local.cloud_access_policy_token
  stack_id                  = data.grafana_cloud_stack.testing_stack.id
  grafana_sa_token          = grafana_cloud_stack_service_account_token.testing_sa_token.key
  grafana_user              = "admin"
}

provider "grafana" {
  url             = data.grafana_cloud_stack.testing_stack.url
  auth            = grafana_cloud_stack_service_account_token.testing_sa_token.key
  stack_id        = data.grafana_cloud_stack.testing_stack.id
  k6_access_token = grafana_k6_installation.k6_installation.k6_access_token
}
