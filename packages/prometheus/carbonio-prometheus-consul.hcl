service = {
  name = "carbonio-prometheus"
  port = 9090
  tags = ["prometheus"]
  check = {
    id       = "prometheus-health"
    name     = "Prometheus Health Check"
    http     = "http://localhost:9090/-/healthy"
    interval = "10s"
    timeout  = "2s"
  }
}