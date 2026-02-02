service {
  name = "carbonio-prometheus-postgres-exporter"
  tags = ["prometheus-exporter"]
  port = 9187

  check {
    id       = "postgres-exporter-health"
    name     = "Postgres Exporter Health Check"
    http     = "http://localhost:9187/metrics"
    interval = "30s"
    timeout  = "5s"
  }
}