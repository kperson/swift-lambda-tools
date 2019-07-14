#!/bin/bash

docker run --rm -v $(pwd):/code --workdir /code swift:5.0.1-xenial swift package --build-path .lambda-build update
