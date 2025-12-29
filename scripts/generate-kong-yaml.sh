#!/bin/bash
set -e

INPUT="apis/onboard-api.json"
OUTPUT="converted-apis/onboard-api.yaml"

mkdir -p converted-apis

SERVICE_NAME=$(jq -r '.service.name' $INPUT)
SERVICE_HOST=$(jq -r '.service.host' $INPUT)
SERVICE_PORT=$(jq -r '.service.port' $INPUT)
SERVICE_PROTOCOL=$(jq -r '.service.protocol' $INPUT)

ROUTE_NAME=$(jq -r '.route.name' $INPUT)

ROUTE_PATHS=$(jq -r '.route.paths[]' $INPUT)

cat > $OUTPUT <<EOF
_workspace: default
_format_version: "3.0"

services:
- name: ${SERVICE_NAME}
  host: ${SERVICE_HOST}
  port: ${SERVICE_PORT}
  protocol: ${SERVICE_PROTOCOL}

  routes:
  - name: ${ROUTE_NAME}
    paths:
EOF

for p in $ROUTE_PATHS; do
echo "    - $p" >> $OUTPUT
done

echo "" >> $OUTPUT
echo "plugins:" >> $OUTPUT

jq -c '.plugins[]' $INPUT | while read plugin; do
  NAME=$(echo $plugin | jq -r '.name')

  echo "- name: $NAME" >> $OUTPUT

  if echo $plugin | jq -e 'has("config")' > /dev/null; then
    echo "  config:" >> $OUTPUT
    echo $plugin | jq -r '.config | to_entries[] | "    \(.key): \(.value)"' >> $OUTPUT
  fi

done

echo "Generated YAML: $OUTPUT"
