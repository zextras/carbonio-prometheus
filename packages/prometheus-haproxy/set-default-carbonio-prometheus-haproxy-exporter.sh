#!/bin/bash

# Get FQDN of the current server
FQDN=$(hostname -f)

# Path to default file
FILE_PATH="/etc/default/carbonio-prometheus-haproxy-exporter"

# ARGs in the file
cat > "$FILE_PATH" <<EOL
ARGS="
--haproxy.scrape-uri='https://$FQDN/haproxy?stats;csv' \\
--no-haproxy.ssl-verify
"
EOL

# Checks that file was created
if [ -f "$FILE_PATH" ]; then
    echo "File $FILE_PATH was created successfully"
    cat "$FILE_PATH"
else
    echo "Error: file $FILE_PATH was not created."
    exit 1
fi

systemctl restart carbonio-prometheus-mysqld-exporter.service