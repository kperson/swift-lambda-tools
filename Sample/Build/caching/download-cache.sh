#!/bin/bash

set -e

if [ ! -z "$BUILD_CACHE_BUCKET" ] && [ "${DOWNLOAD_BUILD_CACHE}" == "1" ] && [ ! -z "$BUILD_CACHE_ZIP" ] && [ ! -d ".lambda-build" ]
then
    cache_exists=$(aws s3 ls $BUILD_CACHE_BUCKET/$BUILD_CACHE_ZIP)
    if [ ! -z "$cache_exists" ]
    then
        aws s3 cp s3://$BUILD_CACHE_BUCKET/$BUILD_CACHE_ZIP $BUILD_CACHE_ZIP
        unzip -q $BUILD_CACHE_ZIP
        rm $BUILD_CACHE_ZIP
    fi
fi
