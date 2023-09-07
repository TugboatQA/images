#!/usr/bin/env bash
set -eu

git diff --name-only origin/main | \
    grep -Eo '^services/[^/]+' | \
    sed -e 's@^services/@@g' | \
    sort | \
    uniq | \
    xargs echo
