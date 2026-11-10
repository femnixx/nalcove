#!/bin/sh
# shelf-trash.sh - Move file/folder to trash
# Usage: shelf-trash.sh <path>

set -eu

path="$1"

# Use gio trash for recoverable deletion
exec gio trash -- "$path"