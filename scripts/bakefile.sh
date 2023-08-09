#!/usr/bin/env bash
set -euo pipefail

DEBUG=${DEBUG-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

echo '{
  "group": {
    "default": {
      "targets": []
    }
  },
  "target": {}
}' > bake.json

for dockerfile in images/*/*/Dockerfile; do
    dir=$(dirname "$dockerfile")
    dest="$dir/image.tar"
    name=$(cat "$dir/NAME")
    tag=$(cut -d' ' -f1 < "$dir/TAGS")
    image=${NAMESPACE}/${name}:${tag}
    key=${image//[:\/\.]/-}

    # If we are not overwriting and the tar already exists and has a size
    # greater than zero, continue to the next Dockerfile.
    if [[ "$OVERWRITE_EXISTING" != "true" ]] && [[ "$OVERWRITE_EXISTING" != "1" ]] && [[ -s "$dest" ]]; then
        echo "Skipping $name; rm $dest or set OVERWRITE_EXISTING to true to overwrite this image" >&2
        continue
    fi

    obj=$(printf '{
        "context": "%s",
        "dockerfile": "Dockerfile",
        "output": ["type=docker,dest=%s"],
        "platforms": ["linux/amd64"],
        "tags": ["%s"],
        "pull": true
    }' "$dir" "$dest" "$image")
    jq --arg key "$key" --argjson obj "$obj" '.target += { ($key): $obj } | .group.default.targets += [$key]' bake.json > newbake.json
    rm bake.json && mv newbake.json bake.json
done
