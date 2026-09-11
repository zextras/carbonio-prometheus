#!/bin/bash

CONFIG_FILE="/etc/default/carbonio-prometheus-postgres-exporter"
DB_USER="carbonio_prometheus"
LEGACY_PASSWORD_HASH="08a8217a3551d3924b8f7683b8d2397d34079a2cb3c90399d2926df2ad43625e"

generate_password() {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8
}

get_config_password() {
  sed -n \
    "s#^DATA_SOURCE_NAME=\"postgresql://${DB_USER}:\([^@]*\)@.*#\1#p" \
    "${CONFIG_FILE}"
}

echo "Configuring PostgreSQL exporter role '${DB_USER}'..."

PASSWORD="$(get_config_password)"
NEW_PASSWORD="${PASSWORD}"
UPDATE_PASSWORD=false

if [ "${PASSWORD}" = "__GENERATED_PASSWORD__" ]; then
  echo "Generating a password for a new installation..."
  NEW_PASSWORD="$(generate_password)"
  UPDATE_PASSWORD=true

elif [ "$(printf '%s' "${PASSWORD}" | sha256sum | awk '{print $1}')" = "${LEGACY_PASSWORD_HASH}" ]; then
  echo "Legacy PostgreSQL exporter password detected. Generating a new password..."
  NEW_PASSWORD="$(generate_password)"
  UPDATE_PASSWORD=true
fi

chown root:root "${CONFIG_FILE}"
chmod 600 "${CONFIG_FILE}"

DB_USER_EXISTS="$(
  su - postgres -c \
    "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'\"" \
    2>/dev/null
)"

if [ "${DB_USER_EXISTS}" = "1" ]; then
  echo "PostgreSQL role '${DB_USER}' already exists. Skipping role creation."

  if [ "${UPDATE_PASSWORD}" = true ]; then
    echo "Updating password for PostgreSQL role '${DB_USER}'..."

    if su - postgres -c \
      "psql --command=\"ALTER USER ${DB_USER} PASSWORD '${NEW_PASSWORD}';\"" \
      >/dev/null; then

      sed -i \
        "s/:${PASSWORD}@/:${NEW_PASSWORD}@/" \
        "${CONFIG_FILE}"

      echo "PostgreSQL exporter password updated successfully."
    else
      echo "WARNING: Failed to update password for PostgreSQL role '${DB_USER}'." >&2
    fi
  fi

else
  echo "PostgreSQL role '${DB_USER}' not found. Creating it..."

  if su - postgres -c \
    "psql --command=\"CREATE USER ${DB_USER} PASSWORD '${NEW_PASSWORD}';\"" \
    >/dev/null; then

    echo "PostgreSQL role '${DB_USER}' created successfully."

    if [ "${UPDATE_PASSWORD}" = true ]; then
      sed -i \
        "s/:${PASSWORD}@/:${NEW_PASSWORD}@/" \
        "${CONFIG_FILE}"
    fi
  else
    echo "WARNING: Failed to create PostgreSQL role '${DB_USER}'." >&2
  fi
fi

echo "Setting search path for '${DB_USER}'..."
su - postgres -c \
  "psql --command=\"ALTER USER ${DB_USER} SET SEARCH_PATH TO postgres_exporter,pg_catalog;\"" \
  >/dev/null

echo "Granting CONNECT permission on database 'postgres'..."
su - postgres -c \
  "psql --command=\"GRANT CONNECT ON DATABASE postgres TO ${DB_USER};\"" \
  >/dev/null

echo "Granting 'pg_monitor' role to '${DB_USER}'..."
su - postgres -c \
  "psql --command=\"GRANT pg_monitor TO ${DB_USER};\"" \
  >/dev/null

echo "PostgreSQL exporter role configuration completed."