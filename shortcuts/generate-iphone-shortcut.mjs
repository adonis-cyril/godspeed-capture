import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import shortcutsJs from "@joshfarrant/shortcuts-js";
import shortcutActions from "@joshfarrant/shortcuts-js/actions.js";

const { actionOutput, buildShortcut, withVariables } = shortcutsJs;
const { ask, conditional, exitShortcut, URL } = shortcutActions;

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, "..");
const envPath = path.join(rootDir, ".env");

loadEnv(envPath);

const notionToken = process.env.NOTION_TOKEN;
const captureBlockId = process.env.NOTION_CAPTURE_BLOCK_ID;

if (!notionToken || !captureBlockId) {
  console.error(
    "Add NOTION_TOKEN and NOTION_CAPTURE_BLOCK_ID to .env before generating the iPhone Shortcut."
  );
  process.exit(1);
}

const apiUrl = `https://api.notion.com/v1/blocks/${captureBlockId}/children`;
const answer = actionOutput("Godspeed Entry");

const getContentsOfURL = {
  WFWorkflowActionIdentifier: "is.workflow.actions.downloadurl",
  WFWorkflowActionParameters: {
    WFHTTPHeaders: dictValue([
      textItem("Authorization", `Bearer ${notionToken}`),
      textItem("Content-Type", "application/json"),
      textItem("Notion-Version", "2022-06-28"),
    ]),
    ShowHeaders: true,
    Advanced: true,
    WFHTTPMethod: "PATCH",
    WFHTTPBodyType: "JSON",
    WFJSONValues: dictValue([
      arrayItem("children", [
        dictItem(null, [
          textItem("object", "block"),
          textItem("type", "to_do"),
          dictItem("to_do", [
            arrayItem("rich_text", [
              dictItem(null, [
                textItem("type", "text"),
                dictItem("text", [
                  textItem("content", withVariables`${answer}`),
                ]),
              ]),
            ]),
            boolItem("checked", false),
          ]),
        ]),
      ]),
    ]),
  },
};

const actions = [
  ask({ inputType: "Text", question: "Godspeed" }, answer),
  ...conditional({
    input: "=",
    value: "",
    ifTrue: [exitShortcut()],
    ifFalse: [],
  }),
  URL({ url: apiUrl }),
  getContentsOfURL,
];

const outputDir = path.join(__dirname, "build");
fs.mkdirSync(outputDir, { recursive: true });
const outputPath = path.join(outputDir, "Godspeed iPhone.unsigned.shortcut");
fs.writeFileSync(outputPath, buildShortcut(actions, { showInWidget: true }));

console.log(`Wrote ${outputPath}`);
console.log(
  "Sign it with: shortcuts sign --mode anyone --input shortcuts/build/Godspeed\\ iPhone.unsigned.shortcut --output shortcuts/build/Godspeed\\ iPhone.shortcut"
);

function loadEnv(filePath) {
  if (!fs.existsSync(filePath)) return;

  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;

    const separator = trimmed.indexOf("=");
    if (separator === -1) continue;

    const key = trimmed.slice(0, separator).trim();
    let value = trimmed.slice(separator + 1).trim();
    value = value.replace(/^["']|["']$/g, "");

    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
}

function textToken(value) {
  return {
    Value: { string: value, attachmentsByRange: {} },
    WFSerializationType: "WFTextTokenString",
  };
}

function textItem(key, value) {
  return {
    WFItemType: 0,
    WFKey: textToken(key),
    WFValue: typeof value === "string" ? textToken(value) : value,
  };
}

function boolItem(key, value) {
  return {
    WFItemType: 4,
    WFKey: textToken(key),
    WFValue: {
      Value: value,
      WFSerializationType: "WFNumberSubstitutableState",
    },
  };
}

function dictItem(key, items) {
  return {
    WFItemType: 1,
    ...(key ? { WFKey: textToken(key) } : {}),
    WFValue: {
      Value: { WFDictionaryFieldValueItems: items },
      WFSerializationType: "WFDictionaryFieldValue",
    },
  };
}

function arrayItem(key, items) {
  return {
    WFItemType: 2,
    WFKey: textToken(key),
    WFValue: {
      Value: items,
      WFSerializationType: "WFArrayParameterState",
    },
  };
}

function dictValue(items) {
  return {
    Value: { WFDictionaryFieldValueItems: items },
    WFSerializationType: "WFDictionaryFieldValue",
  };
}
