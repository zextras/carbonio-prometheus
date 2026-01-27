service = {
  "name" = "carbonio-prometheus-consul-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9107

  check = {
    id       = "consul-exporter-health"
    name     = "Consul Exporter Health Check"
    http     = "http://localhost:9107/metrics"
    interval = "30s"
    timeout  = "5s"
  }
}