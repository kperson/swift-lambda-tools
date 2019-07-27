#!/bin/bash

set -e

if [ ! -z "$BUILD_CACHE_BUCKET" ] && [ "${UPLOAD_BUILD_CACHE}" == "1" ] && [ ! -z "$BUILD_CACHE_ZIP" ]
then
    if [ -d ".lambda-build" ]
    then
        rm -rf .lambda-build
    fi 
    if [ -f "$BUILD_CACHE_ZIP" ]; then
        rm $BUILD_CACHE_ZIP
    fi

    docker_tag=$(terraform output docker_tag)
    docker run --rm -v $(pwd):/out --workdir /code $docker_tag  /bin/bash -c "apt-get -y install zip && zip -q -r $BUILD_CACHE_ZIP .lambda-build && cp $BUILD_CACHE_ZIP /out/$BUILD_CACHE_ZIP"

    aws s3 cp $BUILD_CACHE_ZIP s3://$BUILD_CACHE_BUCKET/$BUILD_CACHE_ZIP    
    rm $BUILD_CACHE_ZIP
fi
