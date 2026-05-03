#!/bin/bash
set -e

if [ ! -f "../../payload/dotnet.tar.gz" ]; then
    echo "--- Downloading .NET Payload ---"
    cd ../../
    mkdir -p payload/rpm payload/dotnet
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 8.0 --install-dir payload/dotnet --architecture x64 --os linux --no-path
    tar -czf payload/dotnet.tar.gz -C payload/dotnet .
    docker run --rm -v $(pwd)/payload/rpm:/payload ghcr.io/mbuccarello/base-fedora:latest \
      /bin/sh -c "dnf install -y 'dnf-command(download)' && dnf download --arch x86_64 --resolve --destdir=/payload libicu krb5-libs"
    cd -
fi

echo "--- Building Debug Image ---"
docker build --platform linux/amd64 -t dotnet-debug -f Dockerfile ../../

echo "--- Verifying Binary ---"
docker run --rm --platform linux/amd64 dotnet-debug --info
