# Configure alerts for the synthetic monitoring checks

# NOTE: In VSCode Terraform extension... the linting seems to be broken for this resource.
resource "grafana_synthetic_monitoring_check_alerts" "http_check_alerts" {
  check_id = grafana_synthetic_monitoring_check.http.id

  alerts = [
    {
      name      = "ProbeFailedExecutionsTooHigh"
      threshold = 1
      period    = "15m"
    },
    {
      name      = "TLSTargetCertificateCloseToExpiring"
      threshold = 14
      period    = ""
    },
    {
      name      = "HTTPRequestDurationTooHighAvg"
      threshold = 5000
      period    = "10m"
    }
  ]
}
