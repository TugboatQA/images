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
        if ! docker ps --all --quiet --no-trunc --filter "id=$container" | grep -q "$container"; then
            printf '\n'
            echo "No container $container" >&2
            return 1
        fi
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
        printf '.' >&2
    done
}

# Cleanup function to stop the specified container
cleanup_container() {
    local container_id="$1"
    if [[ -n "$container_id" ]]; then
        echo "Stopping container: $container_id"
        docker stop "$container_id" >/dev/null 2>&1 || true
    fi
    trap - EXIT INT TERM
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
    container=$(docker run --rm --detach --platform "$platform" "$image")
    # If the script is interrupted, clean up this container.
    trap "cleanup_container $container" EXIT INT TERM
    if ! healthcheck "$container"; then
        echo
        docker logs --follow -n 5 "$container" &
        docker stop "$container" >/dev/null
        echo "❌ $image FAILED"
        exit 1
    fi
    if [[ -x "$dir/test" ]]; then
        echo "Executing additional tests on $image:"
        docker cp --quiet "$dir/test" "$container:/test"
        if ! docker exec "$container" /test 2>&1 | sed 's/^/├── /'; then
            echo
            docker stop "$container" >/dev/null
            echo "└── ❌ $image additional test FAILED"
            exit 1
        fi
        echo "└── ✅ $image additional test PASSED"
    fi
    docker stop "$container" >/dev/null
    echo "✅ $image PASSED"
done
