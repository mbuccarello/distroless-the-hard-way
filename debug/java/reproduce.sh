#!/bin/bash
set -e

if [ ! -f "../../payload/jdk.tar.gz" ]; then
    echo "--- Downloading Java Payload ---"
    cd ../../
    mkdir -p payload/raw payload/stripped
    curl -L "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4+7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.4_7.tar.gz" -o payload/raw/jdk.tar.gz
    tar -xzf payload/raw/jdk.tar.gz -C payload/stripped --strip-components=1
    tar -czf payload/jdk.tar.gz -C payload/stripped .
    cd -
fi

echo "--- Building Debug Image ---"
docker build --platform linux/amd64 -t java-debug -f Dockerfile ../../

echo "--- Verifying Binary ---"
docker run --rm --platform linux/amd64 java-debug -version
