service = {
  "name" = "carbonio-prometheus-mysqld-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9104

  check = {
    id       = "mysqld-exporter-tcp"
    name     = "MySQL Exporter TCP Check"
    tcp      = "localhost:9104"
    interval = "40s"
    timeout  = "5s"
  }
}