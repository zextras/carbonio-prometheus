service {
  name = "carbonio-prometheus-postgres-exporter"
  tags = ["prometheus-exporter"]
  port = 9187

  check {
    id       = "postgres-exporter-tcp"
    name     = "Postgres Exporter TCP Check"
    tcp      = "localhost:9187"
    interval = "40s"
    timeout  = "5s"
  }
}