#!/usr/bin/env bash
set -euo pipefail

echo "matrix=$(find services \
  -type d \
  -maxdepth 1 \
  -mindepth 1 \
  -exec basename {} \; |
  jq -ncrR '[inputs] | map({service: .}) | { include: . }')"
