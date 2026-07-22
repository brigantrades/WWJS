import fs from "node:fs/promises";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = "/Users/brigan/Personal Development/WWJS/outputs/wwjs-brand-guide-20260720";
const outputPath = `${outputDir}/WWJS_Brand_Colors_and_Typography.xlsx`;

const palette = {
  forest: "#263D35",
  sage: "#758675",
  peach: "#E7B89B",
  warmBackground: "#F7F4ED",
  warmWhite: "#FFFDF8",
  charcoal: "#24302C",
  divider: "#DDD8CE",
  gold: "#D5A64E",
};

const colors = [
  ["Warm Background", "#F7F4ED", "Core · Light background", "Main app and scaffold background in light mode"],
  ["Player Ivory", "#F7F2E8", "Core · Light background", "Prayer player, settings and artwork-backed surfaces"],
  ["Dawn Peach", "#E7B89B", "Core · Accent", "Warm decorative highlight and modal accent"],
  ["Sage", "#758675", "Core · Primary accent", "Buttons, completion states, scripture and active controls"],
  ["Forest", "#263D35", "Core · Interactive", "Primary light-theme action color and strong foreground"],
  ["Warm White", "#FFFDF8", "Core · Surface", "Cards, navigation and elevated light-theme surfaces"],
  ["Charcoal", "#24302C", "Core · Text", "Primary light-theme text and color-scheme on-surface"],
  ["Divider", "#DDD8CE", "Core · Border", "Light-theme dividers and quiet separators"],
  ["Disabled", "#E7E3DA", "Core · Disabled", "Disabled controls and inactive thumb color"],
  ["Dark Background", "#17241F", "Core · Dark background", "Main dark-mode app and player background"],
  ["Dark Surface", "#213129", "Core · Dark surface", "Cards and elevated dark-mode surfaces"],
  ["Dark Scheme Text", "#F6F1E7", "Core · Dark text", "Color-scheme on-surface text in dark mode"],
  ["Dark Primary", "#A6B9A4", "Dark theme · Primary", "Material color-scheme primary in dark mode"],
  ["Dark Primary Text", "#F4EAD6", "Dark theme · Text", "Primary semantic text on dark surfaces"],
  ["Dark Secondary Text", "#C6C2B5", "Dark theme · Text", "Supporting copy and secondary labels"],
  ["Muted Gold", "#B8A66F", "Dark theme · Accent", "Primary semantic accent in dark mode"],
  ["Dark Border", "#465D51", "Dark theme · Border", "Subtle borders and surface definition"],
  ["Selected Surface", "#314437", "Dark theme · Selected", "Selected navigation and control surfaces"],
  ["Dark Navigation", "#0C1714", "Dark theme · Navigation", "Dark-mode navigation background"],
  ["Dark Control Surface", "#293B34", "Dark theme · Control", "Control wells and inactive control surfaces"],
  ["Dark Unselected Text", "#94A18B", "Dark theme · Text", "Unselected navigation and muted interface copy"],
  ["Dark Scripture Sage", "#8FA07D", "Dark theme · Scripture", "Scripture text and devotional accents"],
  ["Interactive Cream", "#F2E4C8", "Dark theme · Interactive", "Selected labels, interactive foreground and completion text"],
  ["Selection Gold", "#A88F52", "Dark theme · Outline", "Selection outlines and focused state borders"],
  ["Completion Green", "#5F7854", "Dark theme · Success", "Completed prayer and success surfaces"],
  ["Paywall Background", "#0C3028", "Subscription · Background", "Subscription modal background"],
  ["Paywall Surface", "#12372F", "Subscription · Surface", "Plan cards and raised subscription surfaces"],
  ["Paywall Cream", "#F5EDDE", "Subscription · Text", "Primary paywall text and light button fill"],
  ["Paywall Muted", "#B5BAAF", "Subscription · Text", "Secondary paywall copy"],
  ["Paywall Subtle", "#87958B", "Subscription · Text", "Fine print and tertiary paywall copy"],
  ["Paywall Gold", "#D5A64E", "Subscription · Accent", "Premium highlights, dividers and icons"],
  ["Paywall Pale Gold", "#F2C276", "Subscription · Accent", "Selected states and luminous premium highlights"],
  ["Paywall Border", "#66786D", "Subscription · Border", "Plan-card and subscription surface borders"],
];

const typographyFamilies = [
  ["Generic serif", "Serif", "Regular; Semibold overrides", "Display, headings and the WWJS wordmark", "Flutter ‘serif’; Georgia, then Times New Roman fallbacks"],
  ["Platform default sans-serif", "Sans serif", "Regular / Semibold", "Body copy, buttons, labels and navigation", "Native platform UI font supplied by Flutter"],
];

const hierarchy = [
  ["Display large", "Generic serif", "Regular (400)", "48 px · 1.05", "Be still and know"],
  ["Display medium", "Generic serif", "Regular (400)", "38 px · 1.10", "Today’s Prayer"],
  ["Headline medium", "Generic serif", "Regular (400)", "30 px · 1.20", "What Would Jesus Say?"],
  ["WWJS wordmark", "Generic serif", "Semibold (600)", "30 px · 1.20", "WWJS"],
  ["Title large", "Platform sans-serif", "Semibold (600)", "20 px", "Continue your journey"],
  ["Body large", "Platform sans-serif", "Regular (400)", "17 px · 1.50", "Pray, reflect, and stay close to Jesus."],
  ["Body medium", "Platform sans-serif", "Regular (400)", "15 px · 1.40", "A quiet place for daily prayer."],
  ["Label / primary CTA", "Platform sans-serif", "Semibold (600)", "17 px", "BEGIN PRAYER"],
  ["Navigation label", "Platform sans-serif", "Regular / Semibold", "12 px light · 13 px dark", "Today  ·  Prayers  ·  Settings"],
];

function setColumnWidths(sheet, widths) {
  for (let i = 0; i < widths.length; i += 1) {
    sheet.getRangeByIndexes(0, i, 1, 1).format.columnWidthPx = widths[i];
  }
}

function styleTitle(sheet, title, subtitle, titleFill) {
  sheet.getRange("A1:E1").merge();
  sheet.getRange("A1").values = [[title]];
  sheet.getRange("A1:E1").format = {
    fill: titleFill,
    font: { name: "Georgia", bold: true, size: 22, color: "#FFFFFF" },
    verticalAlignment: "center",
  };
  sheet.getRange("A1:E1").format.rowHeightPx = 58;

  sheet.getRange("A2:E2").merge();
  sheet.getRange("A2").values = [[subtitle]];
  sheet.getRange("A2:E2").format = {
    fill: palette.warmBackground,
    font: { name: "Arial", italic: true, size: 11, color: "#59645F" },
    wrapText: true,
    verticalAlignment: "center",
  };
  sheet.getRange("A2:E2").format.rowHeightPx = 38;
}

function styleHeader(range, fill, fontSize = 11) {
  range.format = {
    fill,
    font: { name: "Arial", bold: true, size: fontSize, color: "#FFFFFF" },
    verticalAlignment: "center",
    wrapText: true,
    borders: { preset: "outside", style: "thin", color: fill },
  };
  range.format.rowHeightPx = 34;
}

function styleNote(sheet, row, text, borderColor = palette.gold) {
  const range = sheet.getRange(`A${row}:E${row}`);
  range.merge();
  sheet.getRange(`A${row}`).values = [[text]];
  range.format = {
    fill: "#FFF4D8",
    font: { name: "Arial", size: 10, color: "#59645F" },
    wrapText: true,
    verticalAlignment: "center",
    borders: { preset: "outside", style: "thin", color: borderColor },
  };
  range.format.rowHeightPx = 52;
}

function styleSource(sheet, row, text) {
  const range = sheet.getRange(`A${row}:E${row}`);
  range.merge();
  sheet.getRange(`A${row}`).values = [[text]];
  range.format = {
    font: { name: "Arial", italic: true, size: 9, color: "#6C756F" },
    verticalAlignment: "center",
  };
  range.format.rowHeightPx = 26;
}

const workbook = Workbook.create();
const colorSheet = workbook.worksheets.add("Colors");
const typeSheet = workbook.worksheets.add("Typography");

// Colors sheet
colorSheet.showGridLines = false;
setColumnWidths(colorSheet, [140, 245, 150, 245, 520]);
styleTitle(
  colorSheet,
  "WWJS — Brand Colors",
  "Warm ivory, forest and sage by day; deep evergreen, cream and muted gold by night.",
  palette.sage,
);
colorSheet.getRange("A4:E4").values = [["Swatch", "Color name", "Hex", "Role", "Recommended use"]];
styleHeader(colorSheet.getRange("A4:E4"), palette.forest);
colorSheet.getRange("A5:E37").values = colors.map(([name, hex, role, use]) => [null, name, hex, role, use]);
colorSheet.getRange("A5:E37").format = {
  fill: palette.warmWhite,
  font: { name: "Arial", size: 10, color: palette.charcoal },
  verticalAlignment: "center",
  wrapText: true,
  borders: { insideHorizontal: { style: "thin", color: palette.divider } },
};
colorSheet.getRange("B5:C37").format.font = { name: "Arial", size: 10, bold: true, color: palette.charcoal };
colorSheet.getRange("A17:E29").format.fill = "#F1F4F0";
colorSheet.getRange("A30:E37").format.fill = "#FBF6EA";
for (let index = 0; index < colors.length; index += 1) {
  const row = 5 + index;
  colorSheet.getRange(`A${row}`).format.fill = colors[index][1];
  colorSheet.getRange(`A${row}:E${row}`).format.rowHeightPx = 32;
}
colorSheet.freezePanes.freezeRows(4);
styleNote(
  colorSheet,
  39,
  "Brand guidance: lead with warm ivory backgrounds, forest/sage accents and charcoal text. Dark mode uses deep evergreen surfaces with cream and muted gold. The subscription experience extends the same forest/cream language with brighter gold highlights. Alpha-based shadows, overlays and glow variants are derived from these base colors and are not listed separately.",
);
styleSource(
  colorSheet,
  41,
  "Source: lib/core/app_theme.dart and lib/widgets/subscription_modal.dart — reviewed 2026-07-20",
);

// Typography sheet
typeSheet.showGridLines = false;
setColumnWidths(typeSheet, [285, 245, 245, 310, 520]);
styleTitle(
  typeSheet,
  "WWJS — Typography",
  "A calm editorial serif for devotional emphasis, paired with the platform’s native sans-serif for clarity.",
  palette.forest,
);
typeSheet.getRange("A4:E4").values = [["Font family", "Classification", "Primary weights", "App usage", "Technical definition"]];
styleHeader(typeSheet.getRange("A4:E4"), palette.sage);
typeSheet.getRange("A5:E6").values = typographyFamilies;
typeSheet.getRange("A5:E6").format = {
  fill: palette.warmWhite,
  font: { name: "Arial", size: 10, color: palette.charcoal },
  wrapText: true,
  verticalAlignment: "center",
  borders: { insideHorizontal: { style: "thin", color: palette.divider } },
};
typeSheet.getRange("A5").format.font = { name: "Georgia", size: 15, bold: true, color: palette.charcoal };
typeSheet.getRange("A6").format.font = { name: "Arial", size: 12, bold: true, color: palette.charcoal };
typeSheet.getRange("A5:E6").format.rowHeightPx = 56;

typeSheet.getRange("A8:E8").merge();
typeSheet.getRange("A8").values = [["App text hierarchy"]];
typeSheet.getRange("A8:E8").format = {
  fill: palette.peach,
  font: { name: "Georgia", bold: true, size: 14, color: palette.charcoal },
  verticalAlignment: "center",
};
typeSheet.getRange("A8:E8").format.rowHeightPx = 38;
typeSheet.getRange("A9:E9").values = [["Role", "Font", "Weight", "Theme size / line height", "Example / guidance"]];
styleHeader(typeSheet.getRange("A9:E9"), "#596A62", 10);
typeSheet.getRange("A10:E18").values = hierarchy;
typeSheet.getRange("A10:E18").format = {
  fill: palette.warmWhite,
  font: { name: "Arial", size: 10, color: palette.charcoal },
  wrapText: true,
  verticalAlignment: "center",
  borders: { insideHorizontal: { style: "thin", color: "#EEE9DF" } },
};
typeSheet.getRange("A10:E18").format.rowHeightPx = 49;
for (const row of [10, 11, 12]) {
  const sizes = { 10: 22, 11: 19, 12: 16 };
  typeSheet.getRange(`E${row}`).format.font = { name: "Georgia", size: sizes[row], color: palette.charcoal };
}
typeSheet.getRange("E13").format.font = { name: "Georgia", size: 16, bold: true, color: palette.charcoal };
typeSheet.getRange("E14").format.font = { name: "Arial", size: 13, bold: true, color: palette.charcoal };
typeSheet.getRange("E15:E17").format.font = { name: "Arial", size: 11, color: palette.charcoal };
typeSheet.getRange("E17").format.font = { name: "Arial", size: 11, bold: true, color: palette.charcoal };
typeSheet.getRange("E18").format.font = { name: "Arial", size: 10, color: palette.charcoal };
styleNote(
  typeSheet,
  20,
  "Production note: the app does not bundle Playfair Display, Inter or another custom font. Display styles explicitly use Flutter’s generic ‘serif’ family with Georgia and Times New Roman fallbacks. Body and interface styles use Flutter’s platform-default sans-serif. A monospace style appears only in isolated technical text and is not part of the core brand system.",
);
styleSource(
  typeSheet,
  22,
  "Source: lib/core/app_theme.dart and lib/widgets/brand_wordmark.dart — reviewed 2026-07-20",
);

await fs.mkdir(outputDir, { recursive: true });

const colorsCheck = await workbook.inspect({
  kind: "table",
  range: "Colors!A1:E41",
  include: "values,formulas",
  tableMaxRows: 45,
  tableMaxCols: 5,
  maxChars: 18000,
});
console.log("COLORS CHECK\n" + colorsCheck.ndjson);

const typographyCheck = await workbook.inspect({
  kind: "table",
  range: "Typography!A1:E22",
  include: "values,formulas",
  tableMaxRows: 25,
  tableMaxCols: 5,
  maxChars: 14000,
});
console.log("TYPOGRAPHY CHECK\n" + typographyCheck.ndjson);

const errorCheck = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 100 },
  summary: "final formula error scan",
});
console.log("ERROR CHECK\n" + errorCheck.ndjson);

for (const [sheetName, fileName] of [["Colors", "wwjs-colors-preview.png"], ["Typography", "wwjs-typography-preview.png"]]) {
  const preview = await workbook.render({ sheetName, autoCrop: "all", scale: 2, format: "png" });
  await fs.writeFile(`${outputDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
console.log(`EXPORTED ${outputPath}`);
