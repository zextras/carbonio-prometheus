service {
  name = "carbonio-prometheus-postfix-exporter"
  tags = ["prometheus-postfix-exporter"]
  port = 9154
  check {
    id       = "postfix-exporter-tcp"
    name     = "Postfix Exporter TCP Check"
    tcp      = "localhost:9154"
    interval = "40s"
    timeout  = "5s"
  }
}