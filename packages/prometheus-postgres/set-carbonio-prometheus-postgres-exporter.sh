#!/bin/bash

# su - postgres -c "psql --command='create USER \"carbonio-prometheus\"  password \"carbonio-prometheus\";'"
# su - postgres -c "psql --command='ALTER USER \"carbonio-prometheus\" SET SEARCH_PATH TO postgres_exporter,pg_catalog;'"
# su - postgres -c "psql --command='GRANT CONNECT ON DATABASE postgres TO \"carbonio-prometheus\";'"
# su - postgres -c "psql --command='GRANT pg_monitor to \"carbonio-prometheus\";'"

su - postgres -c "psql --command=\"create USER carbonio_prometheus PASSWORD 'mb63Q0sV';\""
su - postgres -c "psql --command=\"ALTER USER carbonio_prometheus SET SEARCH_PATH TO postgres_exporter,pg_catalog;\""
su - postgres -c "psql --command=\"GRANT CONNECT ON DATABASE postgres TO carbonio_prometheus;\""
su - postgres -c "psql --command=\"GRANT pg_monitor to carbonio_prometheus;\""
