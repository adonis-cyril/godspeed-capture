#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Godspeed Todo
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ✅
# @raycast.packageName Notion Capture

# Documentation:
# @raycast.description Open a prompt and add the text to a Notion checklist

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

"$PROJECT_DIR/scripts/add-notion-todo.sh"
