#!/bin/bash
set -e

echo "--- Building Go Payload ---"
mkdir -p payload
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o payload/app-go ../../app/test.go

echo "--- Building Debug Image ---"
docker build --platform linux/amd64 -t go-debug -f Dockerfile ../../

echo "--- Verifying Binary ---"
docker run --rm --platform linux/amd64 go-debug

echo "--- Auditing Linked Libraries ---"
echo "Go static binary should have no dynamic links."
docker run --rm --platform linux/amd64 --entrypoint ldd go-debug /usr/bin/app-go || echo "ldd failed (expected for static)"
