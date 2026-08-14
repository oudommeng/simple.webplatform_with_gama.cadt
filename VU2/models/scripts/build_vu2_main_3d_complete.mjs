import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const modelsDirectory = path.resolve(scriptDirectory, "..");

const sourcePaths = {
  config: path.join(modelsDirectory, "internal", "vu2_config.gaml"),
  field: path.join(modelsDirectory, "internal", "field_model.gaml"),
  water: path.join(modelsDirectory, "internal", "water_model.gaml"),
  rice: path.join(modelsDirectory, "internal", "rice_model.gaml"),
  animals: path.join(modelsDirectory, "internal", "animal_model.gaml"),
  damage: path.join(modelsDirectory, "internal", "pest_damage_model.gaml"),
  entry: path.join(modelsDirectory, "vu2-main-3D.gaml"),
};

const outputPath = path.join(modelsDirectory, "vu2-main-3D-complete.gaml");
const sources = Object.fromEntries(
  Object.entries(sourcePaths).map(([name, sourcePath]) => [
    name,
    fs.readFileSync(sourcePath, "utf8").replace(/\r\n/g, "\n"),
  ]),
);

function findMatchingBrace(source, openIndex) {
  let depth = 0;
  let quote = null;
  let lineComment = false;
  let blockComment = false;

  for (let index = openIndex; index < source.length; index += 1) {
    const character = source[index];
    const nextCharacter = source[index + 1];

    if (lineComment) {
      if (character === "\n") lineComment = false;
      continue;
    }

    if (blockComment) {
      if (character === "*" && nextCharacter === "/") {
        blockComment = false;
        index += 1;
      }
      continue;
    }

    if (quote) {
      if (character === "\\") {
        index += 1;
      } else if (character === quote) {
        quote = null;
      }
      continue;
    }

    if (character === "/" && nextCharacter === "/") {
      lineComment = true;
      index += 1;
      continue;
    }

    if (character === "/" && nextCharacter === "*") {
      blockComment = true;
      index += 1;
      continue;
    }

    if (character === '"' || character === "'") {
      quote = character;
      continue;
    }

    if (character === "{") depth += 1;
    if (character === "}") {
      depth -= 1;
      if (depth === 0) return index;
    }
  }

  throw new Error(`Unmatched opening brace at character ${openIndex}`);
}

function extractNamedBlocks(source, keyword) {
  const blocks = [];
  const expression = new RegExp(`^${keyword}\\b[^\\n{]*\\{`, "gm");
  let match;

  while ((match = expression.exec(source)) !== null) {
    const openIndex = source.indexOf("{", match.index);
    const closeIndex = findMatchingBrace(source, openIndex);
    blocks.push(source.slice(match.index, closeIndex + 1).trim());
    expression.lastIndex = closeIndex + 1;
  }

  return blocks;
}

function extractGlobalBody(source) {
  const match = /^global\s*\{/m.exec(source);
  if (!match) return "";

  const openIndex = source.indexOf("{", match.index);
  const closeIndex = findMatchingBrace(source, openIndex);
  return source.slice(openIndex + 1, closeIndex).trim();
}

const globalOrder = ["config", "field", "water", "rice", "animals", "damage", "entry"];
const speciesOrder = ["field", "water", "rice", "animals", "damage"];

const globalSections = globalOrder
  .map((name) => `\t// ${name.toUpperCase()}\n${extractGlobalBody(sources[name])}`)
  .join("\n\n");

const speciesSections = speciesOrder
  .flatMap((name) => extractNamedBlocks(sources[name], "species"))
  .join("\n\n");

const [entryExperiment] = extractNamedBlocks(sources.entry, "experiment");
if (!entryExperiment) throw new Error("Could not find the 3D experiment block");

const completeExperiment = entryExperiment.replace(
  /^experiment\s+vu2_main_3D\b/,
  "experiment vu2_main_3D_complete",
);

const generated = `model cropguard_vu2_main_3D_complete

// AUTO-GENERATED STANDALONE MODEL.
// Contains all VU2 simulation logic and has no GAML imports.
// External runtime assets: CSV files in models/ and clean OBJ/MTL files in ../fbx/gama/.

global {
${globalSections}
}

${speciesSections}

${completeExperiment}
`.replaceAll("../fbx/", "../fbx/gama/");

if (/^import\b/m.test(generated)) {
  throw new Error("Generated model unexpectedly contains a GAML import");
}

fs.writeFileSync(outputPath, generated, "utf8");
console.log(`Generated ${outputPath}`);
