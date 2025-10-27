#!/bin/bash
# Wrapper script to run graph-generator.py using framework's virtual environment

set -e

# Find the script directory (should be .ai-gov/tools when installed)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if venv exists
if [ ! -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    echo "Error: Framework virtual environment not found" >&2
    echo "Please run install.sh to set up the framework" >&2
    exit 1
fi

# Run the graph generator using the framework's Python
exec "$SCRIPT_DIR/venv/bin/python3" "$SCRIPT_DIR/graph-generator.py" "$@"
