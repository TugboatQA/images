#!/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

manifest_list=$1

grep -v '^ *#' < "$manifest_list" | while IFS=" " read -r -a list
do
    list_name=${list[0]}
    echo "Creating multi-platform manifest list $list_name"
    docker manifest rm "$list_name" 2>/dev/null || true
    docker manifest create "${list[@]}"
    docker manifest push "$list_name"
    docker manifest rm "$list_name"
done
