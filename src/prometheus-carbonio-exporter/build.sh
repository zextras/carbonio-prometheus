#!/usr/bin/bash

docker build -t mailbox-experter20 -f Dockerfile20 .
docker create --name mailbox20 mailbox-experter20
docker cp mailbox20:/src/dist/carbonio-mailbox-exporter ./builds/20
docker rm -f mailbox20

docker build -t mailbox-experter22 -f Dockerfile22 .
docker create --name mailbox22 mailbox-experter22
docker cp mailbox22:/src/dist/carbonio-mailbox-exporter ./builds/22
docker rm -f mailbox22

docker build -t mailbox-experter8 -f Dockerfile8 .
docker create --name mailbox8 mailbox-experter8
docker cp mailbox8:/src/dist/carbonio-mailbox-exporter ./builds/8
docker rm -f mailbox8

docker build -t mailbox-experter9 -f Dockerfile9 .
docker create --name mailbox9 mailbox-experter9
docker cp mailbox9:/src/dist/carbonio-mailbox-exporter ./builds/9
docker rm -f mailbox9


