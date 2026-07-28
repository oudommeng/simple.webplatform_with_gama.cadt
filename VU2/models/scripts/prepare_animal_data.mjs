import path from "node:path";
import { fileURLToPath } from "node:url";
import { readCsv, writeCsv } from "./csv_utils.mjs";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const modelsDirectory = path.resolve(scriptDirectory, "..");
const legacyRows = await readCsv(path.join(modelsDirectory, "animal_data.csv"));

const stages = ["vegetative", "reproductive", "ripening"];
const stageNames = {
	vegetative: "Vegetative Stage",
	reproductive: "Reproductive Stage",
	ripening: "Ripening Stage",
};

const scientificNames = {
	"Brown Planthopper": "Nilaparvata lugens",
	"Leaf Folder": "Cnaphalocrocis medinalis",
	"Yellow Stem Borer": "Scirpophaga incertulas",
	"Golden Apple Snail": "Pomacea canaliculata",
	"Lynx Spider": "Oxyopes spp.",
	Trichogramma: "Trichogramma spp.",
	Dragonfly: "Anisoptera",
	Worm: "not_specified",
	Frog: "Anura",
	Wasp: "Hymenoptera",
	"Weaver Ant": "Oecophylla smaragdina",
	Butterfly: "Lepidoptera",
	Bee: "Anthophila",
	Bird: "Aves",
	Rat: "Rattus spp.",
	Ladybug: "Coccinellidae",
	Duck: "Anatidae",
	Snake: "Serpentes",
	Cricket: "Gryllidae",
	Fish: "Actinopterygii",
};

const ecologicalRoles = {
	"Brown Planthopper": "pest",
	"Leaf Folder": "pest",
	"Yellow Stem Borer": "pest",
	"Golden Apple Snail": "pest",
	Rat: "pest",
	Bird: "pest",
	"Lynx Spider": "predator",
	Trichogramma: "parasitoid",
	Dragonfly: "predator",
	Worm: "decomposer",
	Frog: "predator",
	Wasp: "predator",
	"Weaver Ant": "predator",
	Butterfly: "pollinator",
	Bee: "pollinator",
	Ladybug: "predator",
	Duck: "predator",
	Snake: "predator",
	Fish: "predator",
	Cricket: "neutral",
};

function slug(value) {
	return value.toLowerCase().replaceAll(/[^a-z0-9]+/g, "_").replaceAll(/^_|_$/g, "");
}

function movementMode(species, lifeStage) {
	if (lifeStage === "eggs") return "stationary";
	if (["Bird", "Bee", "Butterfly", "Dragonfly", "Wasp", "Trichogramma"].includes(species)) {
		return "fly";
	}
	if (["Fish", "Duck", "Golden Apple Snail"].includes(species)) return "water";
	if (
		[
			"Brown Planthopper",
			"Leaf Folder",
			"Yellow Stem Borer",
			"Ladybug",
			"Lynx Spider",
			"Cricket",
			"Weaver Ant",
		].includes(species)
	) {
		return "plant";
	}
	return "ground";
}

function spawnSurface(species, lifeStage, mode) {
	if (lifeStage === "eggs") {
		return species === "Golden Apple Snail" ? "stem" : "leaf";
	}
	return { fly: "air", water: "water", plant: "plant", ground: "soil" }[mode];
}

function speeds(mode) {
	return {
		stationary: [0, 0],
		fly: [0.2, 0.5],
		water: [0.06, 0.18],
		plant: [0.05, 0.14],
		ground: [0.03, 0.1],
	}[mode];
}

const firstByAnimalId = new Map();
for (const row of legacyRows) {
	if (!firstByAnimalId.has(row.animal_id)) firstByAnimalId.set(row.animal_id, row);
}

const animalTypes = [...firstByAnimalId.values()].map((row) => {
	const speciesId = slug(row.species);
	const mode = movementMode(row.species, row.life_stage);
	const [speedMin, speedMax] = speeds(mode);
	const missingSnailEggAsset = row.animal_id === "golden_apple_snail_eggs";
	const larvaAssetNeedsReview = row.animal_id === "leaf_folder_larva";
	const prefabName = missingSnailEggAsset ? "" : row.prefab_name;

	return {
		animal_id: row.animal_id,
		animal_name: row.animal_name,
		species_id: speciesId,
		species_name: row.species,
		scientific_name: scientificNames[row.species] ?? "not_specified",
		life_stage: row.life_stage === "unspecified" ? "mixed" : row.life_stage,
		ecological_role: ecologicalRoles[row.species] ?? "neutral",
		gama_species: speciesId,
		movement_mode: mode,
		spawn_surface: spawnSurface(row.species, row.life_stage, mode),
		speed_min_m_per_cycle: speedMin,
		speed_max_m_per_cycle: speedMax,
		prefab_name: prefabName,
		unity_resource_path: prefabName
			? `Prefabs/Visual Prefabs/Prefabs/Animals/${prefabName}`
			: "",
		asset_status: missingSnailEggAsset
			? "missing"
			: larvaAssetNeedsReview
				? "needs_review"
				: "configured",
		enabled: "true",
	};
});

const uniqueLegacyRows = [];
const coordinateKeys = new Set();
for (const row of legacyRows) {
	const key = [row.stage_id, row.animal_id, row.x, row.y, row.z].join("|");
	if (!coordinateKeys.has(key)) {
		coordinateKeys.add(key);
		uniqueLegacyRows.push(row);
	}
}

const xValues = uniqueLegacyRows.map((row) => Number(row.x));
const yValues = uniqueLegacyRows.map((row) => Number(row.y));
const sourceBounds = {
	xMin: Math.min(...xValues),
	xMax: Math.max(...xValues),
	yMin: Math.min(...yValues),
	yMax: Math.max(...yValues),
};
const targetHalfSize = 17.5;

function normalize(value, minimum, maximum) {
	return ((value - minimum) / (maximum - minimum)) * targetHalfSize * 2 - targetHalfSize;
}

const groupedSpawnRows = new Map();
for (const row of uniqueLegacyRows) {
	const key = `${row.stage_id}|${row.animal_id}`;
	const group = groupedSpawnRows.get(key) ?? [];
	group.push(row);
	groupedSpawnRows.set(key, group);
}

const spawnPoints = [];
for (const stage of stages) {
	for (const animalType of animalTypes) {
		const rows = groupedSpawnRows.get(`${stage}|${animalType.animal_id}`) ?? [];
		rows.forEach((row, index) => {
			spawnPoints.push({
				stage_id: stage,
				animal_id: animalType.animal_id,
				point_id: index + 1,
				x_local_m: normalize(Number(row.x), sourceBounds.xMin, sourceBounds.xMax).toFixed(4),
				y_local_m: normalize(Number(row.y), sourceBounds.yMin, sourceBounds.yMax).toFixed(4),
				z_m: Math.max(0, Number(row.z)).toFixed(3),
				coordinate_frame: "gama_field_local_m",
				spawn_surface: animalType.spawn_surface,
				spawn_weight: 1,
				source_x: row.x,
				source_y: row.y,
				source_z: row.z,
			});
		});
	}
}

const originalGroup = new Map();
for (const row of legacyRows) {
	originalGroup.set(`${row.stage_id}|${row.animal_id}`, row);
}

const stagePopulations = [];
for (const stage of stages) {
	for (const animalType of animalTypes) {
		const key = `${stage}|${animalType.animal_id}`;
		const original = originalGroup.get(key);
		const sampleSize = (groupedSpawnRows.get(key) ?? []).length;

		if (!original) {
			stagePopulations.push({
				stage_id: stage,
				stage_name: stageNames[stage],
				animal_id: animalType.animal_id,
				species_id: animalType.species_id,
				species_density_per_100m2: 0,
				life_stage_fraction: 0,
				density_sd: "",
				sample_size: 0,
				presence_status: "not_sampled",
				source_id: "legacy_animal_data_v1",
				confidence: "unknown",
				fraction_basis: "not_available",
			});
			continue;
		}

		const sameSpeciesSamples = animalTypes
			.filter((type) => type.species_id === animalType.species_id)
			.reduce(
				(total, type) => total + (groupedSpawnRows.get(`${stage}|${type.animal_id}`) ?? []).length,
				0,
			);
		const speciesHasMultipleLifeStages =
			animalTypes.filter((type) => type.species_id === animalType.species_id).length > 1;

		stagePopulations.push({
			stage_id: stage,
			stage_name: stageNames[stage],
			animal_id: animalType.animal_id,
			species_id: animalType.species_id,
			species_density_per_100m2: original.density_per_100m2,
			life_stage_fraction: (sampleSize / sameSpeciesSamples).toFixed(6),
			density_sd: "",
			sample_size: sampleSize,
			presence_status: "observed",
			source_id: "legacy_animal_data_v1",
			confidence: "low",
			fraction_basis: speciesHasMultipleLifeStages
				? "unique_spawn_point_share"
				: "single_life_stage",
		});
	}
}

await writeCsv(
	path.join(modelsDirectory, "animal_types.csv"),
	[
		"animal_id",
		"animal_name",
		"species_id",
		"species_name",
		"scientific_name",
		"life_stage",
		"ecological_role",
		"gama_species",
		"movement_mode",
		"spawn_surface",
		"speed_min_m_per_cycle",
		"speed_max_m_per_cycle",
		"prefab_name",
		"unity_resource_path",
		"asset_status",
		"enabled",
	],
	animalTypes,
);

await writeCsv(
	path.join(modelsDirectory, "stage_populations.csv"),
	[
		"stage_id",
		"stage_name",
		"animal_id",
		"species_id",
		"species_density_per_100m2",
		"life_stage_fraction",
		"density_sd",
		"sample_size",
		"presence_status",
		"source_id",
		"confidence",
		"fraction_basis",
	],
	stagePopulations,
);

await writeCsv(
	path.join(modelsDirectory, "spawn_points.csv"),
	[
		"stage_id",
		"animal_id",
		"point_id",
		"x_local_m",
		"y_local_m",
		"z_m",
		"coordinate_frame",
		"spawn_surface",
		"spawn_weight",
		"source_x",
		"source_y",
		"source_z",
	],
	spawnPoints,
);

await writeCsv(
	path.join(modelsDirectory, "data_sources.csv"),
	[
		"source_id",
		"title",
		"source_url",
		"sampling_date",
		"location_id",
		"rice_variety",
		"sampling_method",
		"notes",
	],
	[
		{
			source_id: "legacy_animal_data_v1",
			title: "Legacy VU2 animal data",
			source_url: "",
			sampling_date: "not_recorded",
			location_id: "not_recorded",
			rice_variety: "not_recorded",
			sampling_method: "not_recorded",
			notes:
				"Migrated from animal_data.csv. Density uncertainty and field provenance still require confirmation.",
		},
	],
);

console.log(`Generated ${animalTypes.length} animal types.`);
console.log(`Generated ${stagePopulations.length} stage population records.`);
console.log(`Generated ${spawnPoints.length} unique normalized spawn points.`);
console.log(`Removed ${legacyRows.length - uniqueLegacyRows.length} duplicate coordinate records.`);
