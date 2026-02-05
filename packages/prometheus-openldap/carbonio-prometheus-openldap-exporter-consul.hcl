service {
  name = "carbonio-prometheus-openldap-exporter"
  tags = ["prometheus-exporter"]
  port = 9330

  check {
    id       = "openldap-exporter-tcp"
    name     = "OpenLDAP Exporter TCP Check"
    tcp      = "localhost:9330"
    interval = "40s"
    timeout  = "5s"
  }
}