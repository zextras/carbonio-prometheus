service = {
  "name" = "carbonio-prometheus-haproxy-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9101

  check = {
    id       = "haproxy-exporter-health"
    name     = "HAProxy Exporter Health Check"
    http     = "http://localhost:9101/metrics"
    interval = "10s"
    timeout  = "2s"
  }
}