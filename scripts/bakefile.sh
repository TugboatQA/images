#!/usr/bin/env bash
set -euo pipefail

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
    name=${dir#"images/"}
    name=${name//[\/\.]/-}

    # If we are not overwriting and the tar already exists and has a size
    # greater than zero, continue to the next Dockerfile.
    echo $OVERWRITE_EXISTING
    echo $dest
    if [[ "$OVERWRITE_EXISTING" != "true" ]] && [[ "$OVERWRITE_EXISTING" != "1" ]] && [[ -s "$dest" ]]; then
        echo "Skipping $name; set OVERWRITE_EXISTING to true to overwrite this image" >&2
        continue
    fi

    obj=$(printf '{
        "context": "%s",
        "dockerfile": "Dockerfile",
        "output": ["type=docker,dest=%s"],
        "platforms": ["linux/amd64"],
        "pull": true
    }' "$dir" "$dest")
    jq --arg name "$name" --argjson obj "$obj" '.target += { ($name): $obj } | .group.default.targets += [$name]' bake.json > newbake.json
    rm bake.json && mv newbake.json bake.json
done
