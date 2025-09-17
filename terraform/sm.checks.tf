// Define synthetic monitoring checks

data "grafana_synthetic_monitoring_probes" "main" {
  depends_on = [grafana_synthetic_monitoring_installation.sm_installation]
}

resource "grafana_synthetic_monitoring_check" "http" {
  job     = "Validate that the web app is up"
  target  = "https://quickpizza.grafana.com/"
  enabled = true
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes.Ohio,
    data.grafana_synthetic_monitoring_probes.main.probes.Paris,
  ]
  labels = {
    environment = "production"
  }
  settings {
    http {}
  }
}

resource "null_resource" "bundle_backend_test" {
  provisioner "local-exec" {
    command = "npx esbuild ../src/backend/get_recommendation.ts --bundle --outfile=../dist/backend/get_recommendation.js --platform=node --external:k6 --external:https*"
  }
}

resource "grafana_synthetic_monitoring_check" "scripted" {
  job     = "Validate that getting a pizza recommendation works"
  target  = "https://quickpizza.grafana.com/"
  enabled = true
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes.Ohio,
    data.grafana_synthetic_monitoring_probes.main.probes.Paris,
  ]
  labels = {
    environment = "production"
  }
  settings {
    scripted {
      script = file("${path.module}/../dist/backend/get_recommendation.js" )
    }
  }
}