#!/usr/bin/env bash

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

DIR="images/$1"

echo "## Supported Tags for $NAMESPACE/$1"
echo ""

cat ${DIR}/*/TAGS | sort -r | sed 's/\ /`,\ `/g' | sed 's/^/*\ `/g' | sed 's/$/`/g'

echo ""
echo "The above tags are currently supported. Visit https://hub.docker.com/r/$NAMESPACE/$1/tags/ to see a list of all available tags for this image, including those that are no longer supported."
