service = {
  "name" = "carbonio-prometheus-nginx-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9113

  check = {
    id       = "nginx-exporter-tcp"
    name     = "NGINX Exporter TCP Check"
    tcp      = "localhost:9113"
    interval = "40s"
    timeout  = "5s"
  }
}