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

# Always load the images into the local docker image store so they can be
# tested, and also push them to the registry when PUSH is enabled. The marker
# file records which of those happened for each image; see the bake task.
outputs='["type=docker"]'
marker=loaded
if [[ "$PUSH" = "true" ]] || [[ "$PUSH" = "1" ]]; then
    outputs='["type=docker", "type=registry"]'
    marker=pushed
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
# needs to be built, and turn those into bake targets. A pushed image was also
# loaded, so it does not need to be built again just to load it.
shopt -s nullglob
for dockerfile in images/*/*/Dockerfile; do
    dir=$(dirname "$dockerfile")
    if [[ "$overwrite" = "false" ]] && { [[ -f "$dir/$marker" ]] || [[ -f "$dir/pushed" ]]; }; then
        echo "Skipping $dir; rm $dir/$marker or set OVERWRITE_EXISTING to true to overwrite this image" >&2
        continue
    fi
    name=$(cat "$dir/NAME")
    tags=$(cat "$dir/TAGS")
    printf '%s\t%s\t%s\n' "$dir" "$name" "$tags"
done | jq -nR \
    --arg namespace "$NAMESPACE" \
    --argjson outputs "$outputs" \
    --argjson gha "$gha" \
    --argjson cache_to "$cache_to" \
    '[inputs | split("\t") | {dir: .[0], name: .[1], tags: (.[2] | split(" "))}
      | "\(.name)-\(.tags[0] | gsub("\\."; "-"))" as $key
      | "type=gha,scope=\($key),mode=min" as $cache
      | {key: $key, value: ({
          context: .dir,
          dockerfile: "Dockerfile",
          output: $outputs,
          platforms: ["linux/amd64"],
          tags: (.name as $name | .tags | map("\($namespace)/\($name):\(.)")),
          pull: true
        }
        + if $gha then {"cache-from": [$cache]} else {} end
        + if $cache_to then {"cache-to": [$cache]} else {} end)}]
    | {group: {default: {targets: map(.key)}}, target: from_entries}' > bake.json
