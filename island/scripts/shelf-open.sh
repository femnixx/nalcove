#!/bin/sh
# shelf-open.sh - Open file or folder with proper file manager
# Usage: shelf-open.sh <path>

set -eu

path="$1"

# Detect file manager
for fm in nautilus thunar dolphin pcmanfm nemo caja; do
    if command -v "$fm" >/dev/null 2>&1; then
        exec "$fm" -- "$path"
    fi
done

# Fallback to xdg-open (may open terminal if misconfigured)
exec xdg-open -- "$path"