service {
  name = "carbonio-prometheus-node-exporter"
  tags = ["prometheus-exporter"]
  port = 9100

  check {
    id       = "node-exporter-tcp"
    name     = "Node Exporter TCP Check"
    tcp      = "localhost:9100"
    interval = "40s"
    timeout  = "5s"
  }
}