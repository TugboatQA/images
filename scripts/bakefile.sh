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
    name=${dir#"images/"}
    name=${name//[\/\.]/-}
    obj=$(printf '{
        "context": "%s",
        "dockerfile": "Dockerfile",
        "output": ["type=docker,dest=%s/out.tar"],
        "platforms": ["linux/amd64"],
        "pull": true
    }' "$dir" "$dir")
    jq --arg name "$name" --argjson obj "$obj" '.target += { ($name): $obj } | .group.default.targets += [$name]' bake.json > newbake.json
    rm bake.json && mv newbake.json bake.json
done
