#!/bin/bash

set -euo pipefail

# Check for project name argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME="$1"

# Validate required env vars
: "${GRAFANA_API_TOKEN:?Missing GRAFANA_API_TOKEN}"
: "${GRAFANA_STACK_ID:?Missing GRAFANA_STACK_ID}"

echo "Fetching project ID for '$PROJECT_NAME' from Grafana Cloud k6..."

# Make API request
response=$(curl -sS -H "Authorization: Bearer ${GRAFANA_API_TOKEN}" \
                 -H "X-Stack-Id: ${GRAFANA_STACK_ID}" \
                 https://api.k6.io/cloud/v6/projects)

# Extract project ID
project_id=$(echo "$response" | jq -r --arg name "$PROJECT_NAME" '.value[] | select(.name == $name) | .id')

# Fail if not found
if [ -z "$project_id" ]; then
  echo "❌ Error: Could not find project ID for '$PROJECT_NAME'"
  exit 1
fi

# Format variable names
project_env_var="K6_${PROJECT_NAME^^}_PROJECT_ID"

# Output & export
echo "✅ Found project ID: $project_id"
echo "$project_env_var=$project_id" >> "$GITHUB_ENV"
echo "K6_CLOUD_PROJECT_ID=$project_id" >> "$GITHUB_ENV"

# Export to current shell (optional for local usage)
export "$project_env_var=$project_id"
export K6_CLOUD_PROJECT_ID="$project_id"
