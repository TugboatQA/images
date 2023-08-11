#!/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

image=$1

docker push --all-tags "$NAMESPACE/$image"
touch "images/$image/pushed"
