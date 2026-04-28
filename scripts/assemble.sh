#!/bin/bash
set -e
set -o pipefail

# Usage: ./assemble.sh <name> <command...>
NAME=$1
shift
COMMAND="$@"

echo "--- Starting assembly for $NAME ---"
echo "Command: $COMMAND"

# Ensure diag dir exists
mkdir -p /tmp/diag

# Pre-flight: check if name is valid
if [ -z "$NAME" ]; then
    echo "ERROR: Name not provided"
    exit 1
fi

# Run command and capture output
LOG_FILE="/tmp/diag/build.log"

if ! (eval "$COMMAND") 2>&1 | tee "$LOG_FILE"; then
    echo "!!! Assembly for $NAME FAILED !!!"
    
    echo "--- ENVIRONMENT DUMP ---"
    env | sort
    
    echo "--- CONFIG.LOG / CONFIG.SH ANALYSIS ---"
    for diag in config.log config.sh; do
        if [ -f "$diag" ]; then
            echo "--- $diag (Last 200 lines) ---"
            grep -i -B 5 "error:" "$diag" | tail -n 200 || tail -n 200 "$diag"
            cp "$diag" /tmp/diag/
        fi
    done
    
    echo "--- RECENT BUILD LOG ---"
    tail -n 100 "$LOG_FILE"
    
    exit 1
fi

echo "--- Assembly for $NAME SUCCESSFUL ---"

# Sanity check: ensure /rootfs is not empty if it exists
if [ -d "/rootfs" ]; then
    if [ -z "$(ls -A /rootfs)" ]; then
        echo "ERROR: /rootfs is empty! This usually means 'make install DESTDIR=/rootfs' failed to respect the destination root."
        exit 1
    fi
fi

# Binary Audit
# We check in common locations for the produced binary
for bin_path in "/rootfs/usr/local/bin/$NAME" "/rootfs/usr/bin/$NAME" "/usr/local/bin/$NAME"; do
    if [ -f "$bin_path" ]; then
        echo "--- BINARY AUDIT (ldd) for $bin_path ---"
        ldd "$bin_path" || echo "Warning: ldd failed on $bin_path"
        
        echo "--- RPATH CHECK (readelf) ---"
        if command -v readelf >/dev/null; then
            readelf -d "$bin_path" | grep -iE "rpath|runpath" || echo "No RPATH found"
        fi
        break
    fi
done
