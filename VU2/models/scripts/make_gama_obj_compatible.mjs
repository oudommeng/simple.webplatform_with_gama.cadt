import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const assetRoot = path.resolve(scriptDirectory, "..", "..", "fbx");

function triangulateFace(line) {
  const parts = line.trim().split(/\s+/);
  const vertices = parts.slice(1);
  if (vertices.length <= 3) return [line];

  const triangles = [];
  for (let index = 1; index < vertices.length - 1; index += 1) {
    triangles.push(`f ${vertices[0]} ${vertices[index]} ${vertices[index + 1]}`);
  }
  return triangles;
}

function convertObj(sourcePath) {
  const source = fs.readFileSync(sourcePath, "utf8").replace(/\r\n/g, "\n");
  let convertedFaces = 0;
  const output = source
    .split("\n")
    .flatMap((line) => {
	  // GAML supplies display colors, so Blender material files are unnecessary.
	  if (line.startsWith("mtllib ") || line.startsWith("usemtl ")) return [];
      if (!line.startsWith("f ")) return [line];
      const triangles = triangulateFace(line);
      if (triangles.length > 1) convertedFaces += 1;
      return triangles;
    })
    .join("\n");

  const outputPath = sourcePath.replace(/\.obj$/i, ".gama.obj");
  fs.writeFileSync(outputPath, output, "utf8");
  return convertedFaces;
}

function visit(directory) {
  const paths = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) paths.push(...visit(entryPath));
    if (
      entry.isFile()
      && entry.name.toLowerCase().endsWith(".obj")
      && !entry.name.toLowerCase().endsWith(".gama.obj")
    ) {
      paths.push(entryPath);
    }
  }
  return paths;
}

let totalConvertedFaces = 0;
const objPaths = visit(assetRoot);
for (const objPath of objPaths) {
  const convertedFaces = convertObj(objPath);
  totalConvertedFaces += convertedFaces;
  console.log(`${path.relative(assetRoot, objPath)}: triangulated ${convertedFaces} faces`);
}

console.log(`Processed ${objPaths.length} OBJ files; triangulated ${totalConvertedFaces} faces.`);
