#!/bin/bash
set -e

if [ ! -f "../../payload/node.tar.gz" ]; then
    echo "--- Downloading Node.js Payload ---"
    cd ../../
    mkdir -p payload/raw payload/stripped
    curl -L "https://nodejs.org/dist/v22.22.2/node-v22.22.2-linux-x64.tar.xz" -o payload/raw/node.tar.xz
    tar -xJf payload/raw/node.tar.xz -C payload/stripped --strip-components=1
    tar -czf payload/node.tar.gz -C payload/stripped .
    cd -
fi

echo "--- Building Debug Image ---"
docker build --platform linux/amd64 -t nodejs-debug -f Dockerfile ../../

echo "--- Verifying Binary ---"
docker run --rm --platform linux/amd64 nodejs-debug --version
