#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

if [[ -z "${NOTION_TOKEN:-}" || -z "${NOTION_TODO_PAGE_ID:-}" ]]; then
  osascript -e 'display alert "Godspeed Todo is not configured" message "Add NOTION_TOKEN and NOTION_TODO_PAGE_ID to the .env file first."'
  exit 1
fi

NOTION_ANCHOR_HEADING="${NOTION_ANCHOR_HEADING:-${NOTION_SECTION_HEADING:-}}"
NOTION_CAPTURE_HEADING="${NOTION_CAPTURE_HEADING:-Quick Capture}"

if [[ $# -gt 0 ]]; then
  TASK_TEXT="$*"
else
  TASK_TEXT="$(osascript <<'APPLESCRIPT'
try
  display dialog "Add to Notion todo:" default answer "" buttons {"Cancel", "Add"} default button "Add" cancel button "Cancel" with title "Godspeed Todo"
  text returned of result
on error number -128
  return ""
end try
APPLESCRIPT
)"
fi

TASK_TEXT="$(printf '%s' "$TASK_TEXT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

if [[ -z "$TASK_TEXT" ]]; then
  exit 0
fi

notion_api() {
  local method="$1"
  local url="$2"
  local data="${3:-}"

  if [[ -n "$data" ]]; then
    curl -sS -X "$method" "$url" \
      -H "Authorization: Bearer $NOTION_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Notion-Version: 2022-06-28" \
      --data "$data"
  else
    curl -sS -X "$method" "$url" \
      -H "Authorization: Bearer $NOTION_TOKEN" \
      -H "Notion-Version: 2022-06-28"
  fi
}

is_notion_error() {
  python3 - "$1" <<'PY'
import json
import sys

try:
    raise SystemExit(0 if json.loads(sys.argv[1]).get("object") == "error" else 1)
except Exception:
    raise SystemExit(1)
PY
}

notion_error_message() {
  python3 - "$1" <<'PY'
import json
import sys

try:
    print(json.loads(sys.argv[1]).get("message", "Unknown Notion API error"))
except Exception:
    print("Unknown Notion API error")
PY
}

children_url() {
  printf 'https://api.notion.com/v1/blocks/%s/children?page_size=100' "$1"
}

append_url() {
  printf 'https://api.notion.com/v1/blocks/%s/children' "$1"
}

PAGE_CHILDREN="$(notion_api GET "$(children_url "$NOTION_TODO_PAGE_ID")")"

if is_notion_error "$PAGE_CHILDREN"; then
  MESSAGE="$(notion_error_message "$PAGE_CHILDREN")"
  osascript -e "display alert \"Could not read Notion page\" message \"${MESSAGE//\"/\\\"}\""
  exit 1
fi

CAPTURE_BLOCK_ID="$(python3 - "$PAGE_CHILDREN" "$NOTION_CAPTURE_HEADING" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
wanted = sys.argv[2].strip().casefold()

for block in payload.get("results", []):
    block_type = block.get("type")
    if block_type not in {"heading_1", "heading_2", "heading_3", "toggle"}:
        continue

    rich_text = block.get(block_type, {}).get("rich_text", [])
    text = "".join(item.get("plain_text", "") for item in rich_text).strip().casefold()
    if text == wanted:
        print(block["id"])
        break
PY
)"

if [[ -z "$CAPTURE_BLOCK_ID" ]]; then
  AFTER_BLOCK_ID=""

  if [[ -n "$NOTION_ANCHOR_HEADING" ]]; then
    ANCHOR_BLOCK_ID="$(python3 - "$PAGE_CHILDREN" "$NOTION_ANCHOR_HEADING" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
wanted = sys.argv[2].strip().casefold()

for block in payload.get("results", []):
    block_type = block.get("type")
    if block_type not in {"heading_1", "heading_2", "heading_3", "toggle"}:
        continue

    rich_text = block.get(block_type, {}).get("rich_text", [])
    text = "".join(item.get("plain_text", "") for item in rich_text).strip().casefold()
    if text == wanted:
        print(block["id"])
        break
PY
)"

    AFTER_BLOCK_ID="$(python3 - "$PAGE_CHILDREN" "$NOTION_ANCHOR_HEADING" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
wanted = sys.argv[2].strip().casefold()
results = payload.get("results", [])

for index, block in enumerate(results):
    block_type = block.get("type")
    if block_type not in {"heading_1", "heading_2", "heading_3", "toggle"}:
        continue

    rich_text = block.get(block_type, {}).get("rich_text", [])
    text = "".join(item.get("plain_text", "") for item in rich_text).strip().casefold()
    if text == wanted and index > 0:
        print(results[index - 1]["id"])
        break
PY
)"

    if [[ -z "$ANCHOR_BLOCK_ID" ]]; then
      osascript -e "display alert \"Could not find Notion anchor\" message \"No top-level heading named '${NOTION_ANCHOR_HEADING//\'/\\\'}' was found on the configured page.\""
      exit 1
    fi
  fi

  CREATE_HEADING_PAYLOAD="$(python3 - "$NOTION_CAPTURE_HEADING" "$AFTER_BLOCK_ID" <<'PY'
import json
import sys

heading = sys.argv[1]
after_block_id = sys.argv[2]
payload = {
    "children": [
        {
            "object": "block",
            "type": "toggle",
            "toggle": {
                "rich_text": [
                    {
                        "type": "text",
                        "text": {"content": heading}
                    }
                ],
                "children": []
            }
        }
    ]
}
if after_block_id:
    payload["after"] = after_block_id

print(json.dumps(payload))
PY
)"
  CREATE_RESPONSE="$(notion_api PATCH "$(append_url "$NOTION_TODO_PAGE_ID")" "$CREATE_HEADING_PAYLOAD")"

  if is_notion_error "$CREATE_RESPONSE"; then
    MESSAGE="$(notion_error_message "$CREATE_RESPONSE")"
    osascript -e "display alert \"Could not create Notion capture section\" message \"${MESSAGE//\"/\\\"}\""
    exit 1
  fi

  CAPTURE_BLOCK_ID="$(python3 - "$CREATE_RESPONSE" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
results = payload.get("results", [])
if results:
    print(results[0]["id"])
PY
)"
fi

JSON_PAYLOAD="$(python3 - "$TASK_TEXT" <<'PY'
import json
import sys

text = sys.argv[1]
print(json.dumps({
    "children": [
        {
            "object": "block",
            "type": "to_do",
            "to_do": {
                "rich_text": [
                    {
                        "type": "text",
                        "text": {"content": text}
                    }
                ],
                "checked": False
            }
        }
    ]
}))
PY
)"

RESPONSE="$(notion_api PATCH "$(append_url "$CAPTURE_BLOCK_ID")" "$JSON_PAYLOAD")"

if is_notion_error "$RESPONSE"; then
  MESSAGE="$(notion_error_message "$RESPONSE")"
  osascript -e "display alert \"Could not add Notion todo\" message \"${MESSAGE//\"/\\\"}\""
  exit 1
fi

osascript -e 'display notification "Added to Notion" with title "Godspeed Todo"'
