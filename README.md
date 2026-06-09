# Godspeed Capture

A small Mac utility that opens a Raycast-triggered prompt and appends the typed text to a Notion page as an unchecked checklist item.

## What It Does

- `scripts/add-notion-todo.sh` opens a macOS prompt and writes an unchecked `to_do` block to Notion.
- `raycast/godspeed-todo.sh` is the Raycast Script Command wrapper.
- `.env.example` shows the required local configuration.

## Requirements

- macOS
- Raycast
- Bash, Python 3, `curl`, and `osascript`, which are available on most Macs
- A Notion integration token
- A Notion page shared with that integration

## Plan Requirements

This should not require paid plans for personal use.

- Raycast Script Commands are documented as a Raycast feature that can be bound to hotkeys. Raycast's pricing page lists custom extensions and developer tooling in the free plan.
- Notion internal integrations use a static API token. Notion's developer docs require an integration token and page access, but do not state that a paid workspace is required for this basic API workflow.

Official references:

- [Raycast Script Commands](https://manual.raycast.com/script-commands)
- [Raycast Pricing](https://www.raycast.com/pricing)
- [Notion Internal Integrations](https://developers.notion.com/guides/get-started/internal-integrations)

## Setup

For Mac hotkey capture, see [docs/mac-hotkey-setup.md](docs/mac-hotkey-setup.md).

For iPhone lock-screen capture, see [docs/iphone-lock-screen-shortcut.md](docs/iphone-lock-screen-shortcut.md).

Users choose the Notion destination in `.env`: the target page, the capture section name, and an optional anchor heading. The capture section can be an existing top-level toggle, which is useful for personal todo-list layouts.

## UI Elements

The visible Raycast command, macOS prompt, success notification, and Notion capture section are documented in [docs/ui-elements.md](docs/ui-elements.md).

## Security

Do not commit your `.env` file. It contains your Notion token. The repo ignores `.env` by default.
