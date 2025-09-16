data "grafana_synthetic_monitoring_probes" "main" {
  depends_on = [grafana_synthetic_monitoring_installation.sm_installation]
}

resource "grafana_synthetic_monitoring_check" "http" {
  job     = "Validate that QuickPizza is up"
  target  = "https://quickpizza.grafana.com/"
  enabled = true
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes.Ohio,
  ]
  labels = {
    environment = "production"
  }
  settings {
    http {}
  }
}