service = {
  name = "carbonio-prometheus-blackbox-exporter"
  port = 9115
  tags = ["prometheus-exporter"]

  check = {
    id       = "blackbox-exporter-tcp"
    name     = "Blackbox Exporter TCP Check"
    tcp      = "localhost:9115"
    interval = "40s"
    timeout  = "5s"
  }
}