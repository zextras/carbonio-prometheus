service = {
  "name" = "carbonio-prometheus-consul-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9107

  check = {
    id       = "consul-exporter-tcp"
    name     = "Consul Exporter TCP Check"
    tcp      = "localhost:9107"
    interval = "40s"
    timeout  = "5s"
  }
}