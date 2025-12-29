#!/bin/bash
set -e

INPUT_FILE="apis/onboard-api.json"
OUTPUT_DIR="converted-apis"
OUTPUT_FILE="$OUTPUT_DIR/onboard-api.yaml"

mkdir -p "$OUTPUT_DIR"

SERVICE_NAME=$(jq -r '.service_name' $INPUT_FILE)
ROUTE_NAME=$(jq -r '.route_name' $INPUT_FILE)
PATH=$(jq -r '.path' $INPUT_FILE)
HOST=$(jq -r '.host' $INPUT_FILE)
PORT=$(jq -r '.port' $INPUT_FILE)
PROTOCOL=$(jq -r '.protocol' $INPUT_FILE)

RATE_MINUTE=$(jq -r '.plugins["rate-limiting"].minute' $INPUT_FILE)

cat > $OUTPUT_FILE <<EOF
_workspace: default
_format_version: "3.0"

services:
- name: $SERVICE_NAME
  host: $HOST
  port: $PORT
  protocol: $PROTOCOL

  routes:
  - name: $ROUTE_NAME
    paths:
    - $PATH

plugins:
- name: rate-limiting
  config:
    minute: $RATE_MINUTE
    policy: local

- name: key-auth
EOF

echo "Generated YAML: $OUTPUT_FILE"
