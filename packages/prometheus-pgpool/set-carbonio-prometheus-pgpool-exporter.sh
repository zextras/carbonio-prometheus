#!/bin/bash

su - postgres -c "psql --command='create USER \"carbonio-prometheus\";'"
su - postgres -c "psql --command='ALTER USER \"carbonio-prometheus\" SET SEARCH_PATH TO postgres_exporter,pg_catalog;'"
su - postgres -c "psql --command='GRANT CONNECT ON DATABASE postgres TO \"carbonio-prometheus\";'"
su - postgres -c "psql --command='GRANT pg_monitor to \"carbonio-prometheus\";'"