#!/usr/bin/env bash
set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

cat templates/bakefile.template.json > bake.json

for dockerfile in images/*/*/Dockerfile; do
    dir=$(dirname "$dockerfile")
    parent=$(dirname "$dir")
    dest="$dir/image.tar"
    name=$(cat "$dir/NAME")
    tag=$(cut -d' ' -f1 < "$dir/TAGS")
    platform=$(cat "$dir/PLATFORM")
    image=${NAMESPACE}/${name}:${tag}
    key=${image//[:\/\.]/-}
    s3_cache="type=s3,region=$AWS_REGION,bucket=$AWS_S3_BUCKET,name=$key,mode=max"
    cache_block=

    if [[ -n "$AWS_REGION" ]] && [[ -n "$AWS_S3_BUCKET" ]] && [[ -n "$AWS_ACCESS_KEY_ID" ]] && [[ -n "$AWS_SECRET_ACCESS_KEY" ]]; then
        cache_block=$(printf ',"cache-from": ["%s"],"cache-to": ["%s"]' "$s3_cache" "$s3_cache" )
    fi

    # If we are not overwriting and the tar already exists and has a size
    # greater than zero, continue to the next Dockerfile.
    if [[ "$OVERWRITE_EXISTING" != "true" ]] && [[ "$OVERWRITE_EXISTING" != "1" ]] && { [[ -s "$dest" ]] || [[ -f "$parent/built/$key" ]]; }; then
        echo "Skipping $name; rm $dest or set OVERWRITE_EXISTING to true to overwrite this image" >&2
        continue
    fi

    export dir dest platform image cache_block
    obj=$(envsubst < templates/bakefile_target.template.json)

    jq --arg key "$key" --argjson obj "$obj" '.target += { ($key): $obj } | .group.default.targets += [$key]' bake.json > newbake.json
    rm bake.json && mv newbake.json bake.json
done
