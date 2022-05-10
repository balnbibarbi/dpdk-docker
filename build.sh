#!/bin/sh

docker build -t pktgen . && \
docker save pktgen | gzip -c > pktgen.tar.gz
