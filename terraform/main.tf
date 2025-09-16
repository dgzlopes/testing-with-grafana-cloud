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
    for tuple in regexall("(.*?)=(.*)",file("${abspath("${path.module}/../.env")}")) :
    trim(tuple[0], " \t\n\r") => trim(tuple[1], " \t\n\r")
  }
}

# Assign local vars from env map
locals {
  stack_slug                 = local.env["STACK_SLUG"]
  cloud_region              = local.env["CLOUD_REGION"]
  cloud_access_policy_token = local.env["CLOUD_ACCESS_POLICY_TOKEN"]
}

# Step 1: Create the stack
provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = local.cloud_access_policy_token
}

data "grafana_cloud_stack" "testing_stack" {
  provider = grafana.cloud
  slug = local.stack_slug
}

# Step 2: GCk6 service account + token
resource "grafana_cloud_stack_service_account" "gck6_sa" {
  provider   = grafana.cloud
  stack_slug = local.stack_slug

  name        = "${local.stack_slug}-k6-app"
  role        = "Admin"
  is_disabled = false
}

resource "grafana_cloud_stack_service_account_token" "gck6_sa_token" {
  provider   = grafana.cloud
  stack_slug = local.stack_slug

  name               = "${local.stack_slug}-k6-app-token"
  service_account_id = grafana_cloud_stack_service_account.gck6_sa.id
}

# Step 3: Install GCk6. If the app is already installed, this step is a no-op.
resource "grafana_k6_installation" "k6_installation" {
  provider = grafana.cloud

  cloud_access_policy_token = local.cloud_access_policy_token
  stack_id                  = data.grafana_cloud_stack.testing_stack.id
  grafana_sa_token          = grafana_cloud_stack_service_account_token.gck6_sa_token.key
  grafana_user              = "admin"
}

# Step 4: Interact with GCk6
provider "grafana" {
  alias = "k6"

  stack_id        = data.grafana_cloud_stack.testing_stack.id
  k6_access_token = grafana_k6_installation.k6_installation.k6_access_token
}

resource "grafana_k6_project" "my_k6_project" {
  provider = grafana.k6

  name = "k6 Project created with TF"
}
