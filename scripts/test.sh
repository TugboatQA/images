#!/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

dir="services/$1"

if [ -e "${dir}/manifest" ]; then
    source "${dir}/manifest"
fi

# Read in the globals from the manifest and use defaults if empty.
NAME=${NAME:-$1}
SERVICE=${SERVICE:-$NAME}
servicedir="images/${SERVICE}"

if ! [[ -d "$servicedir" ]]; then
    echo "Unable to find built image for $NAME. Have you built it yet?" 1>&2;
    exit 1
fi

healthcheck() {
    container=$1
    timer=0
    timeout=120
    interval=3
    printf 'Starting %s\n' "$image"
    printf 'Waiting for container %s to be healthy\n' "$container"
    while :; do
        healthy=$(docker ps --filter "id=$container" --filter health=healthy --format '{{.Status}}')
        if [[ -n "$healthy" ]]; then
            printf '\n'
            return
        fi
        unhealthy=$(docker ps --filter "id=$container" --filter health=unhealthy --format '{{.Status}}')
        if [[ -n "$unhealthy" ]]; then
            printf '\n'
            return 1
        fi
        sleep $interval
        timer=$((timer + interval))
        if [[ "$timer" -ge "$timeout" ]]; then
            printf '\n'
            return 1
        fi
        printf '.'
    done
}

for x in "$servicedir"/*/NAME; do
    dirname=$(dirname "$x")
    tag=$(basename "$dirname")
    image=$NAMESPACE/$NAME:$tag
    if [[ $(docker inspect "$image" --format '{{.Config.Healthcheck}}') = "<nil>" ]]; then
        echo "$image SKIPPED"
        continue
    fi
    platform=$(cat "$dirname/PLATFORM")
    container=$(docker create --platform "$platform" "$image")
    trap 'docker rm -f "$container" >/dev/null' EXIT
    docker start "$container" >/dev/null
    if ! healthcheck "$container"; then
        echo "$image FAILED"
        exit 1
    else
        echo "$image PASSED"
    fi
    docker rm -f "$container" >/dev/null
    trap - EXIT
done
