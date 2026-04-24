#!/bin/bash
set -e

# Usage: ./assemble.sh <name> <command...>
NAME=$1
shift
COMMAND="$@"

echo "--- Starting assembly for $NAME ---"
echo "Command: $COMMAND"

# Ensure diag dir exists
mkdir -p /tmp/diag

# Run command and capture output
# We use a temporary file to avoid log truncation in console while still being able to grep
LOG_FILE="/tmp/diag/build.log"

if ! (eval "$COMMAND") 2>&1 | tee "$LOG_FILE"; then
    echo "!!! Assembly for $NAME FAILED !!!"
    
    echo "--- ENVIRONMENT DUMP ---"
    env | sort
    
    echo "--- CONFIG.LOG ERROR ANALYSIS (Last 200 lines) ---"
    if [ -f "config.log" ]; then
        grep -i -B 5 "error:" config.log | tail -n 200 || tail -n 200 config.log
        cp config.log /tmp/diag/
    elif [ -f "config.sh" ]; then
        tail -n 200 config.sh
        cp config.sh /tmp/diag/
    fi
    
    echo "--- RECENT BUILD LOG ---"
    tail -n 100 "$LOG_FILE"
    
    exit 1
fi

echo "--- Assembly for $NAME SUCCESSFUL ---"
if [ -f "/rootfs/usr/local/bin/$NAME" ]; then
    echo "--- BINARY AUDIT (ldd) ---"
    ldd "/rootfs/usr/local/bin/$NAME" || true
fi
