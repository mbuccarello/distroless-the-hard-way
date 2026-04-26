#!/bin/bash
set -e

echo "--- Building PHP Debug Image ---"
docker build --platform linux/amd64 -t php-debug .

echo "--- Verifying PHP Binary ---"
docker run --rm --platform linux/amd64 php-debug -v

echo "--- Auditing Linked Libraries ---"
docker run --rm --platform linux/amd64 --entrypoint ldd php-debug /usr/local/bin/php

echo "--- RPATH Inspection ---"
docker run --rm --entrypoint readelf php-debug -d /usr/local/bin/php | grep RPATH || echo "No RPATH found"
