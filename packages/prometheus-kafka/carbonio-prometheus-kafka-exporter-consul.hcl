service = {
  "name" = "carbonio-prometheus-kafka-exporter"
  "tags" = ["prometheus-exporter"]
  "port" = 9081

  check = {
    id       = "kafka-exporter-http"
    name     = "Kafka Exporter HTTP Check"
    http     = "http://localhost:9081/metrics"
    interval = "40s"
    timeout  = "5s"
  }
}
