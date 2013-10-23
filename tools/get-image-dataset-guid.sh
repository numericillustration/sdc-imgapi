#!/bin/bash
#
# Gets an Image dataset guid by piping the image file into an decompressor and
# piping that into zstreamdump
#

if [ "$TRACE" != "" ]; then
    export PS4='${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -o xtrace
fi
set -o errexit
set -o pipefail

#---- globals, config

IMGAPI_URL=http://127.0.0.1
CURL_ARGS="--connect-timeout 10 -sS"

#---- support functions

function fatal () {
    echo "$(basename $0): fatal error: $*"
    exit 1
}

#---- mainline


TOP=$(cd $(dirname $0)/../; pwd)

image_uuid=$1
compression=$2

if [[ -z "$image_uuid" || -z "$compression" ]]; then
    fatal "No Image UUID or Image file compression given"
fi

if [[ "$compression" == "bzip2" ]]; then
    DECOMPRESS="/usr/bin/bzip2 -cdfq"
elif [[ "$compression" == "gzip" ]]; then
    DECOMPRESS="/usr/bin/gzip -cdfq"
elif [[ "$compression" != "none" ]]; then
    fatal "Unsupported $compression type"
fi

toguid=$(
    curl ${CURL_ARGS} --url "${IMGAPI_URL}/images/${image_uuid}/file" \
    | ${DECOMPRESS} \
    | zstreamdump \
	| grep "toguid = " | awk '{ print $3 }'
)

if [[ $? -ne 0 || -z "$toguid" ]]; then
    fatal "error getting Image guid value: $toguid"
fi

echo $toguid

exit 0