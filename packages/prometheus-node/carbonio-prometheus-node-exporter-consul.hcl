service {
  name = "carbonio-prometheus-node-exporter"
  tags = ["prometheus-exporter"]
  port = 9100

  check {
    id       = "node-exporter-health"
    name     = "Node Exporter Health Check"
    http     = "http://localhost:9100/metrics"
    interval = "10s"
    timeout  = "2s"
  }
}