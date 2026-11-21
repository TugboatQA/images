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

dir="services/$1"

if [ -e "${dir}/manifest" ]; then
    source "${dir}/manifest"
fi

# Read in the globals from the manifest and use defaults if empty.
NAME=${NAME:-$1}
SERVICE=${SERVICE:-$NAME}
servicedir="images/${SERVICE}"

# Push the images that bake loaded into docker, so that what gets pushed is
# exactly what was tested.
shopt -s nullglob
for imgdir in "$servicedir"/*/; do
    imgdir=${imgdir%/}
    if [[ "$overwrite" = "false" ]] && [[ -f "$imgdir/pushed" ]]; then
        echo "Skipping $imgdir; rm $imgdir/pushed or set OVERWRITE_EXISTING to true to push this image again" >&2
        continue
    fi
    if ! [[ -f "$imgdir/loaded" ]]; then
        echo "$imgdir has not been built and loaded into docker; run 'task' with PUSH=false first." >&2
        exit 1
    fi
    name=$(cat "$imgdir/NAME")
    read -ra tags < "$imgdir/TAGS"
    for tag in "${tags[@]}"; do
        docker push "$NAMESPACE/$name:$tag"
    done
    touch "$imgdir/pushed"
done
