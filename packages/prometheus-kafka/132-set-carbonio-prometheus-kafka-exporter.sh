#!/bin/bash

pkgname="carbonio-prometheus-kafka-exporter"
config_dir="/etc/carbonio/${pkgname}"
config_file="${config_dir}/${pkgname}.yaml"
kafka_bin="/opt/kafka/bin/kafka-broker-api-versions.sh"

mkdir -p "$config_dir"

# Discover all cluster brokers dynamically using the Kafka CLI tool
brokers=()
if [ -x "$kafka_bin" ]; then
    mapfile -t brokers < <("$kafka_bin" --bootstrap-server localhost:9092 2>/dev/null | awk '/\(id:/ {print $1}' | sort -u)
fi

# Fallback to local endpoint if command fails, returns empty, or Kafka is not yet responding
if [ ${#brokers[@]} -eq 0 ]; then
    brokers=("127.0.0.1:9092")
fi

# Generate YAML configuration
cat <<EOF > "$config_file"
kafka:
  brokers:
EOF

for broker in "${brokers[@]}"; do
    # Strip any carriage returns or stray whitespaces
    clean_broker=$(echo "$broker" | tr -d '\r' | xargs)
    if [ -n "$clean_broker" ]; then
        echo "    - \"$clean_broker\"" >> "$config_file"
    fi
done

cat <<EOF >> "$config_file"

exporter:
  host: "0.0.0.0"
  port: 9081

minion:
  consumerGroups:
    enabled: true
EOF

# Set ownership and security permissions
chown -R carbonio-prometheus:carbonio-prometheus "$config_dir"
chmod 640 "$config_file"

# Restart exporter service if systemd is active
if [ -d /run/systemd/system ]; then
    systemctl restart "${pkgname}.service" >/dev/null 2>&1 || :
fi