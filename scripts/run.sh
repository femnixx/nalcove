#!/bin/bash
# scripts/run.sh - Run the Quickshell Dynamic Island
# Usage: ./scripts/run.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

exec qs -p "$PROJECT_DIR/island"
