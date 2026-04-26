#!/bin/bash
set -e

echo "--- Building Debug Image ---"
docker build --platform linux/amd64 -t static-debug -f Dockerfile ../../

echo "--- Verifying Binary ---"
# This might need adjustment depending on the runtime, we use a generic placeholder
docker run --rm --platform linux/amd64 static-debug --version || true

echo "--- Auditing Linked Libraries ---"
# We try to find the main binary path
MAIN_BIN=$(docker run --rm --platform linux/amd64 --entrypoint sh static-debug -c 'ls /usr/local/bin/* 2>/dev/null | head -n 1 || ls /usr/bin/* 2>/dev/null | grep -v "\." | head -n 1')
if [ -n "$MAIN_BIN" ]; then
    docker run --rm --platform linux/amd64 --entrypoint ldd static-debug $MAIN_BIN || echo "ldd failed (maybe static?)"
    echo "--- RPATH Inspection ---"
    docker run --rm --entrypoint readelf static-debug -d $MAIN_BIN | grep RPATH || echo "No RPATH found"
else
    echo "Could not auto-detect main binary for auditing."
fi
