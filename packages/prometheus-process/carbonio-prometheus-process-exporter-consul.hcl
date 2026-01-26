service {
  name = "carbonio-prometheus-process-exporter"
  tags = ["prometheus-exporter"]
  port = 9256

  check {
    id       = "process-exporter-health"
    name     = "Process Exporter Health Check"
    http     = "http://localhost:9256/metrics"
    interval = "10s"
    timeout  = "2s"
  }
}