#!/bin/bash
set -euo pipefail

# Expect jq path to be injected by pipeline: JQ=tools/jq ./script.sh
if [[ -z "${JQ:-}" ]]; then
  echo "ERROR: JQ variable not set. Call script as: JQ=/path/to/jq ./generate-kong-yaml.sh"
  exit 1
fi

INPUT_FILE="apis/onboard-api.json"
OUTPUT_DIR="converted-apis"
OUTPUT_FILE="$OUTPUT_DIR/onboard-api.yaml"

mkdir -p "$OUTPUT_DIR"

echo "Reading input JSON: $INPUT_FILE"

SERVICE_NAME=$($JQ -r '.service_name' "$INPUT_FILE")
ROUTE_NAME=$($JQ -r '.route_name' "$INPUT_FILE")
ROUTE_PATH=$($JQ -r '.path' "$INPUT_FILE")
HOST=$($JQ -r '.host' "$INPUT_FILE")
PORT=$($JQ -r '.port' "$INPUT_FILE")
PROTOCOL=$($JQ -r '.protocol' "$INPUT_FILE")

RATE_MINUTE=$($JQ -r '.plugins["rate-limiting"].minute' "$INPUT_FILE")

cat > "$OUTPUT_FILE" <<EOF
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
    - "$ROUTE_PATH"

plugins:
- name: rate-limiting
  config:
    minute: $RATE_MINUTE
    policy: local

- name: key-auth
EOF

echo "Generated YAML successfully:"
echo "  $OUTPUT_FILE"
