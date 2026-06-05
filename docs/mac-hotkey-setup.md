# Godspeed Capture Setup

This creates a Raycast command. Press your chosen Raycast hotkey, type a task, and it appends that task as an unchecked Notion checklist item under a top-level capture section.

## 1. Create the Notion integration

1. Go to [Notion integrations](https://www.notion.so/my-integrations).
2. Create an internal integration.
3. Copy the internal integration token.
4. Open the Notion page where you want new checklist items to appear.
5. Click `Share`, invite the integration, and give it edit access.
6. Copy the page URL.

The page ID is the 32-character ID in the Notion URL. Remove hyphens if present.

## 2. Configure the script

From this folder:

```bash
cp .env.example .env
chmod +x scripts/add-notion-todo.sh
```

Edit `.env`:

```bash
NOTION_TOKEN=secret_xxx
NOTION_TODO_PAGE_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NOTION_CAPTURE_HEADING="Quick Capture"
NOTION_ANCHOR_HEADING=""
```

`NOTION_ANCHOR_HEADING` is optional. If you set it, the capture heading is created directly above that top-level heading. If you leave it blank, the capture heading is created at the bottom of the Notion page.

Test it:

```bash
./scripts/add-notion-todo.sh
```

## 3. Install the Raycast command

The Raycast command lives in this project:

```bash
raycast/godspeed-todo.sh
```

Set the hotkey in Raycast:

1. Open Raycast.
2. Open Raycast Settings.
3. Go to `Extensions`.
4. Choose the `Scripts` tab.
5. Click `+`.
6. Choose `Add Script Directory`.
7. Select this repo's `raycast/` folder.
8. Run `Refresh Script Commands`.
9. Search for `Godspeed Todo`.
10. Press `Cmd+K`.
11. Choose `Configure Command`.
12. Set your preferred hotkey.

Raycast owns the global hotkey, so this works from any app once the command is indexed.
