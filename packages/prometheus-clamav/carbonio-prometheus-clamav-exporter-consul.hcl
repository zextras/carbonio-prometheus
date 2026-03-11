service = {
  "name" = "carbonio-prometheus-clamav-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9810

  check = {
    id       = "clamav-exporter-tcp"
    name     = "ClamAV Exporter TCP Check"
    tcp      = "localhost:9810"
    interval = "40s"
    timeout  = "5s"
  }
}