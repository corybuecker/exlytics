#!/bin/bash

set -e
set -u
set -o pipefail

docker run \
    --name exlytics -d \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    -p 5434:5432 \
    -v $(pwd)/migrations/schema.sql:/docker-entrypoint-initdb.d/initialize.sql \
    -e POSTGRES_DB=exlytics \
    -e POSTGRES_USER=exlytics \
    postgres:17.4