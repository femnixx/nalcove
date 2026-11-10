#!/bin/sh
# shelf-add.sh - Add files/folders to the shelf
# Usage: shelf-add.sh <dest-dir> <src>...

set -eu

dest="$1"
shift

mkdir -p -- "$dest"

for src in "$@"; do
    [ -e "$src" ] || continue

    base=$(basename -- "$src")
    if [ -d "$src" ]; then
        name="$base"
        ext=""
    else
        name="${base%.*}"
        ext=".${base##*.}"
        [ "$name" = "$base" ] && ext=""
    fi

    target="$dest/$name$ext"
    n=2
    while [ -e "$target" ]; do
        target="$dest/$name ($n)$ext"
        n=$((n+1))
    done

    cp -a --reflink=auto -- "$src" "$target"
done