service = {
  "name" = "carbonio-prometheus-mysqld-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9104

  check = {
    id       = "mysqld-exporter-health"
    name     = "MySQL Exporter Health Check"
    http     = "http://localhost:9104/metrics"
    interval = "10s"
    timeout  = "2s"
  }
}