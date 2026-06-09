# iPhone Lock-Screen Shortcut Setup

This creates an iPhone Shortcut that asks for text and appends it as a new unchecked Notion to-do under the same capture section used by Godspeed Capture on Mac.

The fixed block ID is the parent heading or toggle block ID for your capture section. Each Shortcut run appends a new child to-do item inside that parent block. It does not overwrite earlier items.

```text
YOUR_CAPTURE_BLOCK_ID
```

## 1. Prepare the Notion Values

You need:

- Your Notion integration token from `.env`
- The parent block ID for your capture heading or toggle:

```text
YOUR_CAPTURE_BLOCK_ID
```

Do not publish or commit the Notion token. It will live only inside the Shortcut on your iPhone.

To get the block ID, open the capture heading or toggle menu in Notion, copy the block link, and use the block ID from the end of the URL. The page must be shared with your Notion integration.

## 2. Create the Shortcut

Open the Shortcuts app on iPhone and create a new Shortcut named `Godspeed`.

Add these actions in order.

### Ask for Input

- Action: `Ask for Input`
- Input type: `Text`
- Prompt: `Godspeed`

### Stop on Empty Input

Add an `If` action:

- Condition: `Provided Input` `is` empty
- Inside the `If` block: add `Stop This Shortcut`
- Leave the `Otherwise` path for the Notion request

### Send the Notion Request

Add `Get Contents of URL`.

Configure it like this:

- URL: `https://api.notion.com/v1/blocks/YOUR_CAPTURE_BLOCK_ID/children`
- Method: `PATCH`
- Headers:
  - `Authorization`: `Bearer YOUR_NOTION_TOKEN`
  - `Content-Type`: `application/json`
  - `Notion-Version`: `2022-06-28`
- Request Body: `JSON`

Replace `YOUR_NOTION_TOKEN` with the real Notion integration token from `.env`.

Build the JSON body in the Shortcut UI with this structure:

```json
{
  "children": [
    {
      "object": "block",
      "type": "to_do",
      "to_do": {
        "rich_text": [
          {
            "type": "text",
            "text": {
              "content": "Provided Input"
            }
          }
        ],
        "checked": false
      }
    }
  ]
}
```

Use the magic variable from `Ask for Input` as the `content` value. Building the body as JSON in Shortcuts keeps quotes and line breaks in your typed text safe.

## 3. Optional: Generate the Shortcut on Mac

You can generate the Shortcut file from JavaScript instead of building it by hand. This uses `@joshfarrant/shortcuts-js`, a third-party Shortcut file generator. The manual setup above is the dependency-free path.

Install dependencies:

```bash
npm install
```

Add the parent capture block ID to `.env`:

```bash
NOTION_CAPTURE_BLOCK_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Generate and sign the Shortcut:

```bash
npm run build:iphone-shortcut
shortcuts sign --mode anyone --input shortcuts/build/Godspeed\ iPhone.unsigned.shortcut --output shortcuts/build/Godspeed\ iPhone.shortcut
open shortcuts/build/Godspeed\ iPhone.shortcut
```

The generated `.shortcut` file contains your Notion token after generation. The repo ignores `*.shortcut` and `shortcuts/build/`, but you should still delete the generated file after importing it.

## 4. Keep Success Silent

Do not add a success notification. If the request succeeds, the Shortcut should finish silently.

To see errors while testing, temporarily add `Show Result` after `Get Contents of URL`. Remove it after the Shortcut works.

## 5. Add It to the Lock Screen

On iPhone:

1. Long press the lock screen.
2. Tap `Customize`.
3. Choose the lock screen.
4. Tap a widget slot.
5. Add the `Shortcuts` widget.
6. Select the `Godspeed` Shortcut.

Now tapping the lock-screen widget opens the text prompt and sends the entry to Notion.

## 6. Test It

Run the Shortcut twice:

```text
buy veggies
take out the trash
```

Confirm both appear as separate unchecked items inside your capture section:

```text
Quick Capture
☐ buy veggies
☐ take out the trash
```

If the Shortcut errors, check the token, the block ID, and whether the Notion page is still shared with the integration.
