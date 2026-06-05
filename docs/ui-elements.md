# UI Elements

Godspeed Capture has three visible UI surfaces.

## Raycast Command

The Raycast command is defined in `raycast/godspeed-todo.sh`.

Default values:

```bash
# @raycast.title Godspeed Todo
# @raycast.mode silent
# @raycast.icon ✅
# @raycast.packageName Notion Capture
# @raycast.description Open a prompt and add the text to a Notion checklist
```

Customize these metadata lines if you want a different command name, icon, or package grouping in Raycast.

## Capture Prompt

The macOS prompt is defined in `scripts/add-notion-todo.sh`.

Default prompt:

```text
Add to Notion todo:
```

Default window title:

```text
Godspeed Todo
```

Default buttons:

```text
Cancel
Add
```

## Completion Notification

After a successful Notion write, the script shows this notification:

```text
Added to Notion
```

Notification title:

```text
Godspeed Todo
```

## Notion Section

The Notion section name comes from `.env`:

```bash
NOTION_CAPTURE_HEADING="Quick Capture"
```

If the section does not exist, the script creates it as a top-level toggle block. New items are appended inside that toggle as unchecked checklist items.
