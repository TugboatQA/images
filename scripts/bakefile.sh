#!/usr/bin/env bash
set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

cat templates/bakefile.template.json > bake.json

# Push straight to the registry when PUSH is enabled, otherwise load the images
# into the local docker image store.
if [[ "$PUSH" = "true" ]] || [[ "$PUSH" = "1" ]]; then
    output="type=registry"
else
    output="type=docker"
fi

for dockerfile in images/*/*/Dockerfile; do
    dir=$(dirname "$dockerfile")
    name=$(cat "$dir/NAME")
    tag=$(cut -d' ' -f1 < "$dir/TAGS")
    # shellcheck disable=SC2016
    tags=$(jq -cR --arg prefix "${NAMESPACE}/${name}:" 'split(" ") | map($prefix + .)' < "$dir/TAGS")
    key=${name}-${tag//\./-}
    cache_block=

    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        cache="type=gha,scope=$key,mode=min"
        cache_block=$(printf ',"cache-from": ["%s"]' "$cache" )
        if [[ "$GITHUB_REF_NAME" = "main" ]]; then
            cache_block=${cache_block}$(printf ',"cache-to": ["%s"]' "$cache" )
        fi
    fi

    # If we are not overwriting and the image was already built, continue to
    # the next Dockerfile.
    if [[ "$OVERWRITE_EXISTING" != "true" ]] && [[ "$OVERWRITE_EXISTING" != "1" ]] && [[ -f "$dir/built" ]]; then
        echo "Skipping $name:$tag; rm $dir/built or set OVERWRITE_EXISTING to true to overwrite this image" >&2
        continue
    fi

    export dir output tags cache_block
    obj=$(envsubst < templates/bakefile_target.template.json)

    jq --arg key "$key" --argjson obj "$obj" '.target += { ($key): $obj } | .group.default.targets += [$key]' bake.json > newbake.json
    rm bake.json && mv newbake.json bake.json
done
