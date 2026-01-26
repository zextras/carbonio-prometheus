service = {
  "name" = "carbonio-prometheus-clamav-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9810

  check = {
    id       = "clamav-exporter-health"
    name     = "ClamAV Exporter Health Check"
    http     = "http://localhost:9810/metrics"
    interval = "10s"
    timeout  = "2s"
  }
}