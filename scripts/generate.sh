#!/usr/bin/env bash

DEBUG=${DEBUG:-false}
if [[ "$DEBUG" = "true" ]] || [[ "$DEBUG" = "1" ]]; then
    set -x
fi

function getTags() {
    temp=$(mktemp -d)
    filter=$1

    SOURCE="${SOURCE:-https://raw.githubusercontent.com/docker-library/official-images/master/library/${NAME}}"
    # Get the official image config, split them into separate temp files
    curl --silent --location --fail --retry 3 "${SOURCE}" | \
        awk -v TEMP="$temp" -v RS= '{ print > (TEMP"/image" ++CNT) }'

    if ! compgen -G "$temp/*" > /dev/null; then
        echo "Unable to find any image config for $NAME" 1>&2;
        exit 1
    fi

    # Parse each image definition individually.
    for file in "$temp"/*; do
        grep '^Tags\|^SharedTags' "${file}" |
            tr '\n' ';' |
            perl -pe 's/;SharedTags:/,/g;' -e 's/;/\n/g' |
            sort |
            sed 's/^.*Tags: //g' |
            grep -v -e alpine -e slim -e onbuild -e windows -e wheezy -e nanoserver -e alpha -e beta |
            ${filter} |
            sed 's/, /,/g'
    done

    # Clean up
    rm -rf "${temp}"
}

dir="services/$1"

if [ -e "${dir}/manifest" ]; then
    source "${dir}/manifest"
fi

# Read in the globals from the manifest and use defaults if empty.
NAME=${NAME:-$1}
FROM=${FROM:-$NAME}
SERVICE=${SERVICE:-$NAME}
FILTER=${FILTER:-cat}
TEMPLATE=${TEMPLATE:-apt}
GETTAGS=${GETTAGS:-getTags}
# Read in comma-separated platforms as a bash array.
IFS=',' read -r -a PLATFORMS <<< "${PLATFORMS:-linux/amd64}"

servicedir="images/${SERVICE}"
mkdir -p "${servicedir}"

for tags in $($GETTAGS "${FILTER}"); do
    tag=$(echo "${tags}" | cut -d, -f1)
    platform_tags=()

    for platform in "${PLATFORMS[@]}"; do
        platform_suffix=$(test "$platform" = "linux/amd64" || echo "-${platform//\//-}")
        imgdir="${servicedir}/${tag}${platform_suffix}"
        image="${FROM}:${tag}"
        mkdir -p "${imgdir}"

        RUN=""
        if [ -e "${dir}/run" ]; then
            cp "${dir}/run" "${imgdir}/run"
            chmod 755 "${imgdir}/run"
            RUN="RUN mkdir -p /etc/service/${SERVICE}\nCOPY run /etc/service/${SERVICE}/run"
            if [ -e "${dir}/finish" ]; then
                cp "${dir}/finish" "${imgdir}/finish"
                chmod 755 "${imgdir}/finish"
                RUN="${RUN}\nCOPY finish /etc/service/${SERVICE}/finish"
            fi
        fi

        dockerfile=/dev/null
        if [ -e "${dir}/Dockerfile" ]; then
            dockerfile="${dir}/Dockerfile"
        fi

        if [ -e "${dir}/files" ]; then
            cp -r "${dir}/files" "${imgdir}/"
        fi

        # shellcheck disable=SC2002
        cat "templates/Dockerfile.${TEMPLATE}.template" | \
            sed "s|{{FROM}}|${image}|g" | \
            sed "/{{DOCKERFILE}}/ r ${dockerfile}" | \
            sed "/{{DOCKERFILE}}/d" | \
            perl -pe "s|\{\{RUN\}\}|${RUN}|g" \
            > "${imgdir}/Dockerfile"

        # If there isn't a suffix, we want all tags and aliases. Otherwise, we
        # just create a single tag with the platform suffix.
        if [[ -z "$platform_suffix" ]]; then
            echo "${tags}" | tr ',' ' ' > "${imgdir}/TAGS"
        else
            platform_tags+=("${tag}${platform_suffix}")
            echo "${tag}${platform_suffix}" > "${imgdir}/TAGS"
        fi
        echo "${NAME}" > "${imgdir}/NAME"
        echo "${platform}" > "${imgdir}/PLATFORM"
    done

    if [[ -n "${platform_tags[*]}" ]]; then
        # Prefix each platform tag with the namespace and image name.
        platform_manifest_image_tags=()
        for platform_tag in "${platform_tags[@]}"; do
            platform_manifest_image_tags+=("${NAMESPACE}/${NAME}:${platform_tag}")
        done
        for x in ${tags//,/ }; do
            echo "${NAMESPACE}/${NAME}:$x ${NAMESPACE}/${NAME}:$x ${platform_manifest_image_tags[*]}" >> "$servicedir/MANIFEST_LIST"
        done
    fi
done
