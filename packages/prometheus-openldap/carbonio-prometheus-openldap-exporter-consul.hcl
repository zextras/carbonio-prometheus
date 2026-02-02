service {
  name = "carbonio-prometheus-openldap-exporter"
  tags = ["prometheus-exporter"]
  port = 9330

  check {
    id       = "openldap-exporter-health"
    name     = "OpenLDAP Exporter Health Check"
    http     = "http://localhost:9330/metrics"
    interval = "30s"
    timeout  = "5s"
  }
}