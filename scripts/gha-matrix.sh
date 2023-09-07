#!/usr/bin/env bash
set -euo pipefail

all_services=$(find services \
                 -type d \
                 -maxdepth 1 \
                 -mindepth 1 \
                 -exec basename {} \;)
SERVICES=${*:-${all_services}}

echo "matrix=$(echo "$SERVICES" |
  jq --slurp -ncrR 'inputs | split("(\n| )";"")[:-1] | map({service: .}) | { include: . }')"
