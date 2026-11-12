#!/usr/bin/env bash
set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

overwrite=false
if [[ "$OVERWRITE_EXISTING" = "true" ]] || [[ "$OVERWRITE_EXISTING" = "1" ]]; then
    overwrite=true
fi

# Push straight to the registry when PUSH is enabled, otherwise load the images
# into the local docker image store.
output="type=docker"
if [[ "$PUSH" = "true" ]] || [[ "$PUSH" = "1" ]]; then
    output="type=registry"
fi

# Read from the GitHub Actions cache, and only write to it from main.
gha=false
if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    gha=true
fi
cache_to=false
if [[ "$gha" = "true" ]] && [[ "${GITHUB_REF_NAME:-}" = "main" ]]; then
    cache_to=true
fi

# Print a tab-separated line of directory, name and tags for each image that
# needs to be built, and turn those into bake targets.
for dockerfile in images/*/*/Dockerfile; do
    dir=$(dirname "$dockerfile")
    if [[ "$overwrite" = "false" ]] && [[ -f "$dir/built" ]]; then
        echo "Skipping $dir; rm $dir/built or set OVERWRITE_EXISTING to true to overwrite this image" >&2
        continue
    fi
    printf '%s\t%s\t%s\n' "$dir" "$(cat "$dir/NAME")" "$(cat "$dir/TAGS")"
done | jq -nR \
    --arg namespace "$NAMESPACE" \
    --arg output "$output" \
    --argjson gha "$gha" \
    --argjson cache_to "$cache_to" \
    '[inputs | split("\t") | {dir: .[0], name: .[1], tags: (.[2] | split(" "))}
      | "\(.name)-\(.tags[0] | gsub("\\."; "-"))" as $key
      | "type=gha,scope=\($key),mode=min" as $cache
      | {key: $key, value: ({
          context: .dir,
          dockerfile: "Dockerfile",
          output: [$output],
          platforms: ["linux/amd64"],
          tags: (.name as $name | .tags | map("\($namespace)/\($name):\(.)")),
          pull: true
        }
        + if $gha then {"cache-from": [$cache]} else {} end
        + if $cache_to then {"cache-to": [$cache]} else {} end)}]
    | {group: {default: {targets: map(.key)}}, target: from_entries}' > bake.json
