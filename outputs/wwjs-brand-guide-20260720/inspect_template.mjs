import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const source = "/Users/brigan/Downloads/Divine_Journey_Brand_Colors_and_Fonts.xlsx";
const outputDir = "/Users/brigan/Personal Development/WWJS/outputs/wwjs-brand-guide-20260720";
const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(source));

const overview = await workbook.inspect({
  kind: "workbook,sheet,table,drawing",
  maxChars: 12000,
  tableMaxRows: 30,
  tableMaxCols: 12,
  tableMaxCellChars: 120,
});
console.log("OVERVIEW\n" + overview.ndjson);

for (const sheetName of ["Colors", "Typography"]) {
  const region = await workbook.inspect({
    kind: "region,computedStyle",
    sheetId: sheetName,
    range: "A1:L40",
    maxChars: 16000,
  });
  console.log(`\n${sheetName.toUpperCase()}\n${region.ndjson}`);
  const preview = await workbook.render({ sheetName, autoCrop: "all", scale: 2, format: "png" });
  await fs.writeFile(`${outputDir}/template-${sheetName.toLowerCase()}.png`, new Uint8Array(await preview.arrayBuffer()));
}
