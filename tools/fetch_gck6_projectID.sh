#!/bin/bash

set -euo pipefail

# Usage check
if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME="$1"

: "${GRAFANA_API_TOKEN:?Missing GRAFANA_API_TOKEN}"
: "${GRAFANA_STACK_ID:?Missing GRAFANA_STACK_ID}"

echo "Fetching project ID for '$PROJECT_NAME' from Grafana Cloud k6..."

response=$(curl -sS -H "Authorization: Bearer ${GRAFANA_API_TOKEN}" \
                 -H "X-Stack-Id: ${GRAFANA_STACK_ID}" \
                 https://api.k6.io/cloud/v6/projects)

project_id=$(echo "$response" | jq -r --arg name "$PROJECT_NAME" '.value[] | select(.name == $name) | .id')

if [ -z "$project_id" ]; then
  echo "Error: Could not find project ID for '$PROJECT_NAME'"
  exit 1
fi

var_name="K6_${PROJECT_NAME^^}_PROJECT_ID"  # Uppercase and underscores
echo "$var_name=$project_id"
export "$var_name=$project_id"
