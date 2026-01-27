consul {
  address    = "127.0.0.1:8500"
  token_file = "/etc/carbonio/carbonio-prometheus-alertmanager/service-discover/token"
}

template {
  source      = "/etc/zextras/service-discover/templates/alertmanager.yml.ctmpl"
  destination = "/etc/carbonio/carbonio-prometheus-alertmanager/alertmanager.yml"
  perms       = 0640
  command     = "systemctl restart carbonio-prometheus-alertmanager.service"
}