service = {
  name = "carbonio-prometheus-blackbox-exporter"
  port = 9115
  tags = ["prometheus-exporter"]

  check = {
    id       = "blackbox-exporter-health"
    name     = "Blackbox Exporter Health Check"
    http     = "http://localhost:9115/metrics"
    interval = "10s"
    timeout  = "2s"
  }
}