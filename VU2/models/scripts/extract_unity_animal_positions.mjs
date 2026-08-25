import path from "node:path";
import { fileURLToPath } from "node:url";
import { readCsv, writeCsv } from "./csv_utils.mjs";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const modelsDirectory = path.resolve(scriptDirectory, "..");
const unityRoot = path.resolve(
	modelsDirectory,
	"..",
	"..",
	"..",
	"simple.CADT.VU2",
	"Assets",
	"Resources",
	"Prefabs",
	"Visual Prefabs",
);

const stages = [
	{
		stage_id: "vegetative",
		stage_name: "Vegetative Stage",
		file: "animal_positions_vegetative_stage.csv",
	},
	{
		stage_id: "reproductive",
		stage_name: "Reproductive Stage",
		file: "animal_positions_reproductive_stage.csv",
	},
	{
		stage_id: "ripening",
		stage_name: "Ripening Stage",
		file: "animal_positions_ripening_stage.csv",
	},
];

const prefabToAnimal = {
	SM_BPH_Eggs: {
		animal_id: "brown_planthopper_eggs",
		animal_name: "Brown Planthopper - Eggs",
		species: "Brown Planthopper",
		life_stage: "eggs",
	},
	SM_BPH_Nymph: {
		animal_id: "brown_planthopper_nymph",
		animal_name: "Brown Planthopper - Nymph",
		species: "Brown Planthopper",
		life_stage: "nymph",
	},
	SM_BrownPlantHopper_01: {
		animal_id: "brown_planthopper_adult",
		animal_name: "Brown Planthopper - Adult",
		species: "Brown Planthopper",
		life_stage: "adult",
	},
	SM_GLF_Eggs: {
		animal_id: "leaf_folder_eggs",
		animal_name: "Leaf Folder - Eggs",
		species: "Leaf Folder",
		life_stage: "eggs",
	},
	SM_GLF_Nymph: {
		animal_id: "leaf_folder_larva",
		animal_name: "Leaf Folder - Larva",
		species: "Leaf Folder",
		life_stage: "larva",
	},
	SM_GreenLeafFolder_01: {
		animal_id: "leaf_folder_adult",
		animal_name: "Leaf Folder - Adult",
		species: "Leaf Folder",
		life_stage: "adult",
	},
	SM_YSB_Eggs: {
		animal_id: "yellow_stem_borer_eggs",
		animal_name: "Yellow Stem Borer - Eggs",
		species: "Yellow Stem Borer",
		life_stage: "eggs",
	},
	SM_YellowStemBorer_01: {
		animal_id: "yellow_stem_borer_adult",
		animal_name: "Yellow Stem Borer - Adult",
		species: "Yellow Stem Borer",
		life_stage: "adult",
	},
	SM_GAS_Eggs: {
		animal_id: "golden_apple_snail_eggs",
		animal_name: "Golden Apple Snail - Eggs",
		species: "Golden Apple Snail",
		life_stage: "eggs",
	},
	SM_GoldenAppleSnail_01: {
		animal_id: "golden_apple_snail_adult",
		animal_name: "Golden Apple Snail - Adult",
		species: "Golden Apple Snail",
		life_stage: "adult",
	},
	SM_Native_Snail_01: {
		animal_id: "native_snail_adult",
		animal_name: "Native Snail - Adult",
		species: "Native Snail",
		life_stage: "adult",
	},
	SM_River_Snail_01: {
		animal_id: "river_snail_adult",
		animal_name: "River Snail - Adult",
		species: "River Snail",
		life_stage: "adult",
	},
	SM_Rat_01: { animal_id: "rat", animal_name: "Rat", species: "Rat", life_stage: "unspecified" },
	SM_Bird_01: { animal_id: "bird", animal_name: "Bird", species: "Bird", life_stage: "unspecified" },
	SM_Ladybug_01: {
		animal_id: "ladybug",
		animal_name: "Ladybug",
		species: "Ladybug",
		life_stage: "unspecified",
	},
	SM_Dragonfly_01: {
		animal_id: "dragonfly",
		animal_name: "Dragonfly",
		species: "Dragonfly",
		life_stage: "unspecified",
	},
	SM_Duck_01: { animal_id: "duck", animal_name: "Duck", species: "Duck", life_stage: "unspecified" },
	SM_Fish_01: { animal_id: "fish", animal_name: "Fish", species: "Fish", life_stage: "unspecified" },
	SM_Frog_01: { animal_id: "frog", animal_name: "Frog", species: "Frog", life_stage: "unspecified" },
	SM_WeaverAnt_01: {
		animal_id: "weaver_ant",
		animal_name: "Weaver Ant",
		species: "Weaver Ant",
		life_stage: "unspecified",
	},
	SM_Spider_01: {
		animal_id: "lynx_spider",
		animal_name: "Lynx Spider",
		species: "Lynx Spider",
		life_stage: "unspecified",
	},
	SM_Wasp_01: { animal_id: "wasp", animal_name: "Wasp", species: "Wasp", life_stage: "unspecified" },
	SM_Trichogramma_01: {
		animal_id: "trichogramma",
		animal_name: "Trichogramma",
		species: "Trichogramma",
		life_stage: "unspecified",
	},
	SM_Worm_01: { animal_id: "worm", animal_name: "Worm", species: "Worm", life_stage: "unspecified" },
	SM_Bee_01: { animal_id: "bee", animal_name: "Bee", species: "Bee", life_stage: "unspecified" },
	SM_Butterfly_01: {
		animal_id: "butterfly",
		animal_name: "Butterfly",
		species: "Butterfly",
		life_stage: "unspecified",
	},
	SM_Cricket_01: {
		animal_id: "cricket",
		animal_name: "Cricket",
		species: "Cricket",
		life_stage: "unspecified",
	},
	SM_Snake_01: { animal_id: "snake", animal_name: "Snake", species: "Snake", life_stage: "unspecified" },
};

function prefabName(row) {
	return path.basename(row.prefab_asset, ".prefab");
}

function formatNumber(value) {
	const number = Number(value);
	if (!Number.isFinite(number)) return "";
	return number.toFixed(6).replace(/\.?0+$/u, "");
}

const legacyRows = await readCsv(path.join(modelsDirectory, "animal_data.csv"));
const densityByStageAnimal = new Map();
const densityByStageSpecies = new Map();
for (const row of legacyRows) {
	if (Number(row.density_per_100m2) > 0) {
		densityByStageAnimal.set(`${row.stage_id}|${row.animal_id}`, row.density_per_100m2);
		densityByStageSpecies.set(`${row.stage_id}|${row.species}`, row.density_per_100m2);
	}
}

const extracted = [];
const skipped = new Map();
const spawnCounts = new Map();

for (const stage of stages) {
	const rows = await readCsv(path.join(unityRoot, stage.file));
	for (const row of rows) {
		const prefab = prefabName(row);
		const animal = prefabToAnimal[prefab];
		if (!animal) {
			skipped.set(prefab, (skipped.get(prefab) ?? 0) + 1);
			continue;
		}

		const key = `${stage.stage_id}|${animal.animal_id}`;
		const spawnIndex = (spawnCounts.get(key) ?? 0) + 1;
		spawnCounts.set(key, spawnIndex);

		extracted.push({
			stage_id: stage.stage_id,
			stage_name: stage.stage_name,
			animal_id: animal.animal_id,
			animal_name: animal.animal_name,
			species: animal.species,
			life_stage: animal.life_stage,
			prefab_name: prefab,
			prefab_path: row.prefab_asset,
			density_per_100m2:
				densityByStageAnimal.get(key) ??
				densityByStageSpecies.get(`${stage.stage_id}|${animal.species}`) ??
				"1",
			spawn_index: spawnIndex,
			x: formatNumber(row.world_x),
			y: formatNumber(row.world_z),
			z: formatNumber(row.world_y),
		});
	}
}

await writeCsv(
	path.join(modelsDirectory, "animal_data.csv"),
	[
		"stage_id",
		"stage_name",
		"animal_id",
		"animal_name",
		"species",
		"life_stage",
		"prefab_name",
		"prefab_path",
		"density_per_100m2",
		"spawn_index",
		"x",
		"y",
		"z",
	],
	extracted,
);

console.log(`Extracted ${extracted.length} modeled animal placement rows.`);
for (const [prefab, count] of [...skipped.entries()].sort(([left], [right]) => left.localeCompare(right))) {
	console.warn(`Skipped ${count} rows for unmapped prefab ${prefab}.`);
}
