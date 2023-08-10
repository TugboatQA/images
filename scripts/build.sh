#!/usr/bin/env bash

set -eo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

parent=images/"$1"

mkdir -p "$parent/built"

for tarball in "$parent"/*/image.tar; do
    # Ensure the tarball exists and is larger than zero bytes.
    test -s "$tarball"

    dir=$(dirname "$tarball")
    name=$(cat "$dir/NAME")
    tag=$(cut -d' ' -f1 < "$dir/TAGS")
    # shellcheck disable=SC2207
    aliases=($(cut -d' ' -f2- < "$dir/TAGS"))
    image=${NAMESPACE}/${name}:${tag}
    key=${image//[:\/\.]/-}

    if [[ -f "$parent/built/$key" ]] && [[ "$OVERWRITE_EXISTING" != "true" ]] && [[ "$OVERWRITE_EXISTING" != "1" ]]; then
        echo "Skipping $image; rm $parent/built/$key or set OVERWRITE_EXISTING to true to rebuild this image" >&2
        continue
    fi

    temp=$(mktemp -d)
    trap 'rm -rf $temp' EXIT SIGINT

    # Extract the tarball to the temp directory.
    tar -C "$temp" -xf "$tarball"

    # Remove volumes and entrypoint from the manifest.
    config=$(jq -r '.[0].Config' "${temp}/manifest.json")
    jq 'del(.config.Volumes,.config.Entrypoint)' "${temp}/${config}" > "${temp}/config.json"
    mv -f "${temp}/config.json" "${temp}/${config}"
    tar -C "$temp" -c . | docker load

    touch "$parent/built/$key"

    for alias in "${aliases[@]}"; do
        alias_tag="${NAMESPACE}/${name}:${alias}"
        alias_key=${alias_tag//[:\/\.]/-}
        docker tag "$image" "$alias_tag"
        touch "$parent/built/$alias_key"
    done

    # If we've gotten this far, it's safe to delete the tarball.
    rm "$tarball"
done
