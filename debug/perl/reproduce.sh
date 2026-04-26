#!/bin/bash
set -e

echo "--- Building Perl Debug Image ---"
docker build --platform linux/amd64 -t perl-debug .

echo "--- Verifying Perl Binary ---"
docker run --rm --platform linux/amd64 perl-debug --version

echo "--- Auditing Linked Libraries ---"
docker run --rm --platform linux/amd64 --entrypoint ldd perl-debug /usr/local/bin/perl

echo "--- RPATH Inspection ---"
docker run --rm --platform linux/amd64 --entrypoint readelf perl-debug -d /usr/local/bin/perl | grep RPATH || echo "No RPATH found"
