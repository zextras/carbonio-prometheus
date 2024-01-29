services {
  checks = [
    {
      id       = "live",
      http     = "http://127.0.0.1:9090/-/healthy",
      method   = "GET",
      timeout  = "1s"
      interval = "5s"
      status   = "passing"
      failures_before_critical = 1
    },
    {
      id       = "ready",
      http     = "http://127.0.0.1:9090/-/ready",
      method   = "GET",
      timeout  = "1s"
      interval = "5s"
      status   = "passing"
      failures_before_critical = 1
    }
  ],
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
