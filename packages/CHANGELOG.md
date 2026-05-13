# Changelog

All notable changes to this project will be documented in this file. 


### [0.14.0] (2026-6-10)


### Features
* Split Prometheus scrape jobs into separate configuration files under /etc/carbonio/carbonio-prometheus/scrape_config.d/ and enabled loading them via scrape_config_files
* Added Blackbox monitoring jobs and rules for additional service endpoint checks
* Updated MTA queue alert rules to use job="postfix" metrics instead of job="node"
* Added alerting rules for exporter endpoint availability monitorings
* Switched OpenLDAP exporter source from mlorenzo-stratio/openldap_exporter to markusmazurczak/openldap_exporter due to lack of maintenance in the previous upstream
* Upgraded Carbonio Prometheus to 3.11.3 version (based on https://github.com/prometheus/prometheus/releases/tag/v3.11.3)
* Move the 30-day TSDB retention setting from the deprecated CLI flag to `prometheus.yml`
* Upgraded Carbonio Prometheus Alertmanager to 0.32.1 version (based on https://github.com/prometheus/alertmanager/releases/tag/v0.32.1)
* Upgraded Carbonio Prometheus ClamAV to 1.0.1 version (based on https://github.com/r3kzi/clamav-prometheus-exporter/releases/tag/v1.0.1)
* Upgraded Carbonio Prometheus Mysqld exporter to 0.19.0 (based on https://github.com/prometheus/mysqld_exporter/releases/tag/v0.19.0)
* Upgraded Carbonio Prometheus Node exporter to 1.11.1 (based on https://github.com/prometheus/node_exporter/releases/tag/v1.11.1)
* Upgraded Carbonio Prometheus Postgres exporter to 0.19.1 version (based on https://github.com/prometheus-community/postgres_exporter/releases/tag/v0.19.1)


### Bug Fixes
* Fixed Prometheus Python client dependency for RHEL-based distributions
* Fixed OpenLDAP exporter configuration to use the local LDAP host FQDN instead of the global LDAP host in HA deployments


### [0.13.0] (2026-3-11)


### Features
* Upgraded Carbonio Prometheus to 3.9.1 version (based on https://github.com/prometheus/prometheus/releases/tag/v3.9.1)
* Upgraded Carbonio Prometheus Alertmanager to 0.31.0 version (based on https://github.com/prometheus/alertmanager/releases/tag/v0.30.1)
* Upgraded Carbonio Prometheus Blackbox exporter to 0.28.0 version (based on https://github.com/prometheus/blackbox_exporter/releases/tag/v0.28.0)
* Upgraded Carbonio Prometheus Postgres exporter to 0.19.0 version (based on https://github.com/prometheus-community/postgres_exporter/releases/tag/v0.19.0)
* Implemented metrics collection for monitoring installed Carbonio package versions
* Added Consul monitoring for missing nodes and services
* Centralized Alertmanager configuration management via Consul KV
* Added new carbonio-prometheus-postfix-exporter to monitor Postfix mail queues and statistics


### Bug Fixes
* Fixed a bug in the carbonio-prometheus user directory: '/' replaced with the correct directory for existing infrastructures
* Limited concurrent requests in the exporter with --consul.request-limit=5 to enhance monitoring reliability and reduce infrastructure load.


### [0.12.0] (2025-12-16)


### Features
* Added Prometheus service to Consul
* Upgraded Carbonio Prometheus to 3.7.3 version (based on https://github.com/prometheus/prometheus/releases/tag/v3.7.3)
* Upgraded Carbonio Prometheus Alertmanager to 0.29.0 version (based on https://github.com/prometheus/alertmanager/releases/tag/v0.29.0)
* Upgraded Carbonio Prometheus Mysqld exporter to 0.18.0 (based on https://github.com/prometheus/mysqld_exporter/releases/tag/v0.18.0)
* Upgraded Carbonio Prometheus Nginx exporter to 1.5.1 (based on https://github.com/nginx/nginx-prometheus-exporter/releases/tag/v1.5.1)
* Upgraded Carbonio Prometheus Node exporter to 1.10.2 (based on https://github.com/prometheus/node_exporter/releases/tag/v1.10.2)
* Upgraded Carbonio Prometheus Postgres exporter to 0.18.1 (based on https://github.com/prometheus-community/postgres_exporter/releases/tag/v0.18.1)
* Enabled Alertmanager service by default
* Added basic Prometheus alerting rules


### Bug Fixes
* Fixed carbonio-prometheus user HOME: replaced '/' with a proper directory
* Fixed "Unexpected response code: 403 (Permission denied: token with AccessorID..)" issue


### [0.11.0] (2025-8-25)


### Features
* Added Prometheus services to carbonio.target
* Upgraded Carbonio Prometheus to 3.5.0 version (based on https://github.com/prometheus/prometheus/releases/tag/v3.5.0)
* Upgraded Carbonio Prometheus Blackbox exporter to 0.27.0 version (based on https://github.com/prometheus/blackbox_exporter/releases/tag/v0.27.0)


### [0.10.0] (2025-6-09)


### Features
* Upgraded Carbonio Prometheus to 3.4.0 version (based on https://github.com/prometheus/prometheus/releases/tag/v3.4.0)
* Upgraded Carbonio Prometheus Alertmanager to 0.28.1 version (based on https://github.com/prometheus/alertmanager/releases/tag/v0.28.1)
* Upgraded Carbonio Prometheus Consul exporter to 0.13.0 (based on https://github.com/prometheus/consul_exporter/releases/tag/v0.13.0)
* Upgraded Carbonio Prometheus Clamav exporter to 1.0.0 version (based on https://github.com/r3kzi/clamav-prometheus-exporter/releases/tag/v1.0.0)
* Upgraded Carbonio Prometheus Mysql exporter to 0.17.2 version (based on https://github.com/prometheus/mysqld_exporter/releases/tag/v0.17.2)
* Upgraded Carbonio Prometheus Nginx exporter to 1.4.2 version (based on https://github.com/nginx/nginx-prometheus-exporter/releases/tag/v1.4.2)
* Upgraded Carbonio Prometheus Node exporter to 1.9.1 version (based on https://github.com/prometheus/node_exporter/releases/tag/v1.9.1)
* Upgraded Carbonio Prometheus Postgres exporter to 0.17.1 version (based on https://github.com/prometheus-community/postgres_exporter/releases/tag/v0.17.1)
* Upgraded Carbonio Prometheus Process exporter to 0.8.7 version (based on https://github.com/ncabatoff/process-exporter/releases/tag/v0.8.7)


### Bug Fixes
* Fixed prometheus.yml config (typo in rabbitmq job) 
* Added missed config file for Carbonio Prometheus Postgres exporter


### [0.9.11] (2025-2-11)


### Features
* Removed Carbonio Pgpool exporter
* Added Carbonio HAProxy exporter
* Upgraded Carbonio Clamav exporter 
* Modified prometheus.yuml config according to changes provided above



# Changelog

All notable changes to this project will be documented in this file. 
