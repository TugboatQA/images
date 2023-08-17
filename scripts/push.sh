#!/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

image=$1

if [[ -f "images/$image/pushed" ]] && [[ "$OVERWRITE_EXISTING" != "true" ]] && [[ "$OVERWRITE_EXISTING" != "1" ]]; then
    echo "Skipping $image; rm images/$image/pushed or set OVERWRITE_EXISTING to true to rebuild this image" >&2
    exit
fi

docker push --all-tags "$NAMESPACE/$image"
touch "images/$image/pushed"
