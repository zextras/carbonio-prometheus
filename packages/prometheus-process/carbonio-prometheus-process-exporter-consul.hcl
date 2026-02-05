service {
  name = "carbonio-prometheus-process-exporter"
  tags = ["prometheus-exporter"]
  port = 9256

  check {
    id       = "process-exporter-tcp"
    name     = "Process Exporter TCP Check"
    tcp      = "localhost:9256"
    interval = "40s"
    timeout  = "5s"
  }
}