service = {
  name = "carbonio-prometheus-blackbox-exporter"
  port = 9115
  tags = ["prometheus-exporter"]

  check = {
    id       = "blackbox-exporter-health"
    name     = "Blackbox Exporter Health Check"
    http     = "http://localhost:9115/metrics"
    interval = "30s"
    timeout  = "5s"
  }
}