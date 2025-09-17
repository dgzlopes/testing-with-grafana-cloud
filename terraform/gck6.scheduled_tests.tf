// Define scheduled tests

resource "grafana_k6_load_test" "functional_test" {
  project_id = grafana_k6_project.web_app_project.id
  name       = "Functional Test"
  script     = file("${path.module}/../src/web_app/get_recommendation.ts")
}

resource "grafana_k6_schedule" "daily" {
  load_test_id = grafana_k6_load_test.functional_test.id
  starts       = "2024-12-25T10:00:00Z"
  recurrence_rule {
    frequency = "DAILY"
    interval  = 1
  }
}