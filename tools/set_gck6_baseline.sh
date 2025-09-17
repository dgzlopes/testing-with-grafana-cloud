#!/bin/bash

# -------------------------------
# Usage:
#   K6_TEST_RUN_IDS='{"file1.ts":"123","file2.ts":"456"}' ./set_gck6_baseline.sh
# Requires:
#   K6_CLOUD_TOKEN
# -------------------------------

set -euo pipefail

: "${K6_CLOUD_TOKEN:?Missing K6_CLOUD_TOKEN}"
: "${K6_TEST_RUN_IDS:?Missing K6_TEST_RUN_IDS}"

RUN_IDS=$(echo "$K6_TEST_RUN_IDS" | jq -r 'values[]')

for TEST_RUN_ID in $RUN_IDS; do
  echo "📌 Setting test run $TEST_RUN_ID as baseline..."

  response=$(curl -sS -X POST "https://api.k6.io/cloud/v2/runs/$TEST_RUN_ID/make_baseline" \
    -H "Authorization: Bearer ${K6_CLOUD_TOKEN}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json")

  if echo "$response" | grep -q '"status":"error"'; then
    echo "❌ Failed to set baseline for test run $TEST_RUN_ID"
    echo "$response"
    exit 1
  else
    echo "✅ Baseline set for test run $TEST_RUN_ID"
  fi
done
