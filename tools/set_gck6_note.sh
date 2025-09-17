#!/bin/bash

# -----------------------------------------
# Usage:
#   K6_TEST_RUN_IDS='{"file1.ts":"123","file2.ts":"456"}' \
#   GIT_BRANCH=main RELEASE_NAME=v1.2.3 \
#   ./set_gck6_note.sh
#
# Requires:
#   K6_CLOUD_TOKEN, GRAFANA_STACK_ID
# -----------------------------------------

set -euo pipefail

: "${K6_CLOUD_TOKEN:?Missing K6_CLOUD_TOKEN}"
: "${GRAFANA_STACK_ID:?Missing GRAFANA_STACK_ID}"
: "${K6_TEST_RUN_IDS:?Missing K6_TEST_RUN_IDS}"

BRANCH="${GIT_BRANCH:-unknown}"
RELEASE="${RELEASE_NAME:-}"

RUN_IDS=$(echo "$K6_TEST_RUN_IDS" | jq -r 'values[]')

for TEST_RUN_ID in $RUN_IDS; do
  echo "📌 Saving test run $TEST_RUN_ID..."

  save_code=$(curl -sS -o /dev/null -w "%{http_code}" \
    -X POST "https://api.k6.io/cloud/v6/test_runs/${TEST_RUN_ID}/save" \
    -H "Authorization: Bearer ${K6_CLOUD_TOKEN}" \
    -H "X-Stack-Id: ${GRAFANA_STACK_ID}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json")

  if [[ "$save_code" == "204" ]]; then
    echo "✅ Saved test run $TEST_RUN_ID"
  elif [[ "$save_code" == "409" ]]; then
    echo "⚠️ Test run $TEST_RUN_ID already deleted or save limit reached"
  else
    echo "❌ Failed to save test run $TEST_RUN_ID (HTTP $save_code)"
    exit 1
  fi

  note="branch=${BRANCH}"
  if [[ -n "$RELEASE" ]]; then
    note+=" release=${RELEASE}"
  fi

  echo "📝 Setting note: $note"

  note_code=$(curl -sS -o /dev/null -w "%{http_code}" \
    -X PATCH "https://api.k6.io/cloud/v6/test_runs/${TEST_RUN_ID}" \
    -H "Authorization: Bearer ${K6_CLOUD_TOKEN}" \
    -H "X-Stack-Id: ${GRAFANA_STACK_ID}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"note\":\"${note}\"}")

  if [[ "$note_code" == "204" ]]; then
    echo "✅ Note set for test run $TEST_RUN_ID"
  else
    echo "❌ Failed to set note for test run $TEST_RUN_ID (HTTP $note_code)"
    exit 1
  fi
done
