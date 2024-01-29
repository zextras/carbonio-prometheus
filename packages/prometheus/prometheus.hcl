services {
  check{
      id       = "ready",
      http     = "http://127.0.0.1:9090/-/ready",
      method   = "GET",
      timeout  = "1s"
      interval = "5s"
    }
  connect {
    sidecar_service {
      proxy {
        local_service_address = "127.0.0.1"
      }
    }
  }

  name = "carbonio-prometheus"
  port = 9090
}
