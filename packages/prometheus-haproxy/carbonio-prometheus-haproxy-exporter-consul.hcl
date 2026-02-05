service = {
  "name" = "carbonio-prometheus-haproxy-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9101

  check = {
    id       = "haproxy-exporter-tcp"
    name     = "HAProxy Exporter TCP Check"
    tcp      = "localhost:9101"
    interval = "40s"
    timeout  = "5s"
  }
}