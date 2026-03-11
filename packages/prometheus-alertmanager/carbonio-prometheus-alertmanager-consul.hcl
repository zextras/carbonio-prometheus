service = {
  name = "carbonio-prometheus-alertmanager"
  port = 9095
  tags = ["alertmanager"]
  check = {
    id       = "alertmanager-health"
    name     = "Alertmanager Health Check"
    http     = "http://localhost:9095/-/healthy"
    interval = "10s"
    timeout  = "2s"
  }
}