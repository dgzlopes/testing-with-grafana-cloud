// Define GCk6 projects and their limits/quotas

resource "grafana_k6_project" "backend_project" {
  name = "backend"
}

resource "grafana_k6_project" "web_app_project" {
  name = "web_app"
}

resource "grafana_k6_project_limits" "backend_project_limits" {
  project_id              = grafana_k6_project.backend_project.id
  vuh_max_per_month       = 1000
  vu_max_per_test         = 100
  vu_browser_max_per_test = 10
  duration_max_per_test   = 3600
}

resource "grafana_k6_project_limits" "web_app_project_limits" {
  project_id              = grafana_k6_project.web_app_project.id
  vuh_max_per_month       = 2000
  vu_max_per_test         = 200
  vu_browser_max_per_test = 20
  duration_max_per_test   = 7200
}