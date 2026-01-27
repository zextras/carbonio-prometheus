service = {
  "name" = "carbonio-prometheus-nginx-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9113

  check = {
    id       = "nginx-exporter-health"
    name     = "NGINX Exporter Health Check"
    http     = "http://localhost:9113/metrics"
    interval = "30s"
    timeout  = "5s"
  }
}