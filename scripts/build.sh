#!/usr/bin/env bash

set -e

tarball=$1
platform=${2-linux/amd64}

# Ensure the tarball exists and is larger than zero bytes.
test -s "$tarball"

dir=$(dirname "$tarball")
parent=$(dirname "$dir")
name=$(cat "$dir/NAME")
tag=$(cut -d' ' -f1 < "$dir/TAGS")
# shellcheck disable=SC2207
aliases=($(cut -d' ' -f2- < "$dir/TAGS"))
image=${NAMESPACE}/${name}:${tag}

if grep -q "^$image\$" "$parent/built" 2>/dev/null && [[ "$OVERWRITE" != "true" ]]; then
    echo "Skipping $image; set OVERWRITE to true to overwrite this image"
    exit
fi

temp=$(mktemp -d)
trap 'rm -rf $temp' EXIT SIGINT

# Extract the tarball to the temp directory.
tar -C "$temp" -xf "$tarball"

# Remove volumes and entrypoint from the manifest.
config=$(jq -r '.[0].Config' "${temp}/manifest.json")
jq 'del(.config.Volumes,.config.Entrypoint)' "${temp}/${config}" > "${temp}/config.json"
mv -f "${temp}/config.json" "${temp}/${config}"
tar -C "$temp" -c . | docker image import --platform "$platform" - "$image"

echo "$image" >> "$parent/built"

for alias in "${aliases[@]}"; do
    alias_tag="${NAMESPACE}/${name}:${alias}"
    docker tag "$image" "$alias_tag"
    echo "$alias_tag" >> "$parent/built"
done

# If we've gotten this far, it's safe to delete the tarball.
rm "$tarball"
