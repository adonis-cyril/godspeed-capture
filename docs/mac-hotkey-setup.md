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

## 3. Choose the Destination

Godspeed Capture stores entries in a Notion page and capture section chosen by the user.

`NOTION_TODO_PAGE_ID` is the Notion page where entries are stored. Copy the page URL from Notion and use the 32-character page ID from that URL. The page must be shared with the Notion integration.

`NOTION_CAPTURE_HEADING` is the section that receives new entries. If it does not exist, the script creates it as a top-level toggle block. Every new entry is appended inside it as an unchecked checklist item.

`NOTION_ANCHOR_HEADING` is optional. If you set it, the capture section is created directly above that existing top-level heading. If you leave it blank, the capture section is created at the bottom of the Notion page.

Common setups:

```bash
# Create or use "Quick Capture" at the bottom of the page.
NOTION_CAPTURE_HEADING="Quick Capture"
NOTION_ANCHOR_HEADING=""
```

```bash
# Create or use "Inbox" directly above an existing "Today" heading.
NOTION_CAPTURE_HEADING="Inbox"
NOTION_ANCHOR_HEADING="Today"
```

```bash
# Use an existing top-level toggle called "Godspeed Notes".
# New entries are stored inside that toggle.
NOTION_CAPTURE_HEADING="Godspeed Notes"
NOTION_ANCHOR_HEADING=""
```

If someone wants entries inside an existing toggle block, they should name that toggle in `NOTION_CAPTURE_HEADING`. The script looks for a matching top-level toggle or heading first. If it finds one, it appends entries inside it. If it does not find one, it creates a new top-level toggle with that name.

Test it:

```bash
./scripts/add-notion-todo.sh
```

## 4. Install the Raycast command

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
