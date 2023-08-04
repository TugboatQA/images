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
    test "$OVERWRITE" = "false" && test -s "$dest" && echo "skipping $name" && continue

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
rm -f newbake.json
