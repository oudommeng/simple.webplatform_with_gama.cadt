import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { readCsv } from "./csv_utils.mjs";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const modelsDirectory = path.resolve(scriptDirectory, "..");

const animalTypes = await readCsv(path.join(modelsDirectory, "animal_types.csv"));
const populations = await readCsv(path.join(modelsDirectory, "stage_populations.csv"));
const spawnPoints = await readCsv(path.join(modelsDirectory, "spawn_points.csv"));
const sources = await readCsv(path.join(modelsDirectory, "data_sources.csv"));
const animalModel = await fs.readFile(
	path.join(modelsDirectory, "internal", "animal_model.gaml"),
	"utf8",
);
const vrModel = await fs.readFile(path.join(modelsDirectory, "vu2_main-VR.gaml"), "utf8");

const errors = [];
const warnings = [];
const stages = ["vegetative", "reproductive", "ripening"];
const validStatuses = new Set(["observed", "absent", "not_sampled"]);
const validModes = new Set(["stationary", "plant", "ground", "fly", "water"]);
const validAssetStatuses = new Set(["configured", "needs_review", "missing"]);
const validConfidence = new Set(["high", "medium", "low", "unknown"]);

function checkHeaders(name, rows, expected) {
	const actual = rows.length > 0 ? Object.keys(rows[0]) : [];
	if (actual.join("|") !== expected.join("|")) {
		errors.push(`${name}: expected headers ${expected.join(", ")}`);
	}
}

function number(value, label) {
	const parsed = Number(value);
	if (!Number.isFinite(parsed)) errors.push(`${label}: expected a number, received "${value}"`);
	return parsed;
}

function uniqueBy(rows, key, label) {
	const seen = new Set();
	for (const row of rows) {
		const value = key(row);
		if (seen.has(value)) errors.push(`${label}: duplicate key ${value}`);
		seen.add(value);
	}
}

checkHeaders("animal_types.csv", animalTypes, [
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
]);
checkHeaders("stage_populations.csv", populations, [
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
]);
checkHeaders("spawn_points.csv", spawnPoints, [
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
]);
checkHeaders("data_sources.csv", sources, [
	"source_id",
	"title",
	"source_url",
	"sampling_date",
	"location_id",
	"rice_variety",
	"sampling_method",
	"notes",
]);

uniqueBy(animalTypes, (row) => row.animal_id, "animal_types.csv");
uniqueBy(populations, (row) => `${row.stage_id}|${row.animal_id}`, "stage_populations.csv");
uniqueBy(
	spawnPoints,
	(row) => `${row.stage_id}|${row.animal_id}|${row.point_id}`,
	"spawn_points.csv",
);
uniqueBy(sources, (row) => row.source_id, "data_sources.csv");

const animalById = new Map(animalTypes.map((row) => [row.animal_id, row]));
const sourceIds = new Set(sources.map((row) => row.source_id));
const gamaSpecies = new Set(animalTypes.map((row) => row.gama_species));

for (const species of gamaSpecies) {
	if (!animalModel.includes(`species ${species} parent: animal_template`)) {
		errors.push(`animal_model.gaml: missing GAMA species ${species}`);
	}
	if (!vrModel.includes(`geometry_properties("${species}","animal"`)) {
		errors.push(`vu2_main-VR.gaml: missing Unity property for ${species}`);
	}
	if (!vrModel.includes(`add_geometries_to_send(${species},`)) {
		errors.push(`vu2_main-VR.gaml: ${species} is not sent to Unity`);
	}
}

for (const row of animalTypes) {
	for (const field of [
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
	]) {
		if (!row[field]) errors.push(`animal_types.csv ${row.animal_id}: ${field} is required`);
	}
	if (!validModes.has(row.movement_mode)) {
		errors.push(`animal_types.csv ${row.animal_id}: invalid movement_mode`);
	}
	if (!validAssetStatuses.has(row.asset_status)) {
		errors.push(`animal_types.csv ${row.animal_id}: invalid asset_status`);
	}
	if (!new Set(["true", "false"]).has(row.enabled)) {
		errors.push(`animal_types.csv ${row.animal_id}: enabled must be true or false`);
	}

	const speedMin = number(row.speed_min_m_per_cycle, `${row.animal_id} speed_min`);
	const speedMax = number(row.speed_max_m_per_cycle, `${row.animal_id} speed_max`);
	if (speedMin < 0 || speedMax < speedMin) {
		errors.push(`animal_types.csv ${row.animal_id}: invalid speed range`);
	}
	if (row.movement_mode === "stationary" && (speedMin !== 0 || speedMax !== 0)) {
		errors.push(`animal_types.csv ${row.animal_id}: stationary animals must have zero speed`);
	}

	if (row.asset_status === "configured") {
		if (!row.prefab_name || !row.unity_resource_path) {
			errors.push(`animal_types.csv ${row.animal_id}: configured prefab is incomplete`);
		}
		if (!row.unity_resource_path.startsWith("Prefabs/Visual Prefabs/Prefabs/Animals/")) {
			errors.push(`animal_types.csv ${row.animal_id}: invalid Unity resource path`);
		}
	}
	if (row.unity_resource_path.includes("\\")) {
		errors.push(`animal_types.csv ${row.animal_id}: use forward slashes in Unity paths`);
	}
	if (row.asset_status !== "configured") {
		warnings.push(`${row.animal_id}: prefab status is ${row.asset_status}`);
	}
}

const expectedPopulationRows = stages.length * animalTypes.length;
if (populations.length !== expectedPopulationRows) {
	errors.push(
		`stage_populations.csv: expected ${expectedPopulationRows} explicit stage/type rows, found ${populations.length}`,
	);
}

for (const row of populations) {
	if (!stages.includes(row.stage_id)) errors.push(`${row.animal_id}: invalid stage ${row.stage_id}`);
	if (!animalById.has(row.animal_id)) errors.push(`${row.animal_id}: unknown animal_id`);
	if (animalById.has(row.animal_id) && row.species_id !== animalById.get(row.animal_id).species_id) {
		errors.push(`${row.stage_id}|${row.animal_id}: species_id does not match animal_types.csv`);
	}
	if (!validStatuses.has(row.presence_status)) {
		errors.push(`${row.stage_id}|${row.animal_id}: invalid presence_status`);
	}
	if (!sourceIds.has(row.source_id)) errors.push(`${row.animal_id}: unknown source_id`);
	if (!validConfidence.has(row.confidence)) {
		errors.push(`${row.stage_id}|${row.animal_id}: invalid confidence`);
	}

	const density = number(
		row.species_density_per_100m2,
		`${row.stage_id}|${row.animal_id} density`,
	);
	const fraction = number(row.life_stage_fraction, `${row.stage_id}|${row.animal_id} fraction`);
	const sampleSize = number(row.sample_size, `${row.stage_id}|${row.animal_id} sample_size`);
	if (row.density_sd !== "") {
		const densitySd = number(row.density_sd, `${row.stage_id}|${row.animal_id} density_sd`);
		if (densitySd < 0) errors.push(`${row.stage_id}|${row.animal_id}: density_sd must be non-negative`);
	}
	if (density < 0 || fraction < 0 || fraction > 1 || sampleSize < 0) {
		errors.push(`${row.stage_id}|${row.animal_id}: population values are outside valid ranges`);
	}
	if (row.presence_status === "observed" && (density <= 0 || fraction <= 0 || sampleSize <= 0)) {
		errors.push(`${row.stage_id}|${row.animal_id}: observed records require positive values`);
	}
	if (row.presence_status !== "observed" && (density !== 0 || fraction !== 0 || sampleSize !== 0)) {
		errors.push(`${row.stage_id}|${row.animal_id}: non-observed records must contain zeros`);
	}
}

for (const stage of stages) {
	const speciesIds = new Set(animalTypes.map((row) => row.species_id));
	for (const speciesId of speciesIds) {
		const rows = populations.filter(
			(row) =>
				row.stage_id === stage &&
				row.species_id === speciesId &&
				row.presence_status === "observed",
		);
		if (rows.length === 0) continue;

		const fractionTotal = rows.reduce((sum, row) => sum + Number(row.life_stage_fraction), 0);
		if (Math.abs(fractionTotal - 1) > 0.00001) {
			errors.push(`${stage}|${speciesId}: life-stage fractions total ${fractionTotal}`);
		}
		if (new Set(rows.map((row) => row.species_density_per_100m2)).size !== 1) {
			errors.push(`${stage}|${speciesId}: life stages must share one species density`);
		}
	}
}

const duplicateCoordinates = new Set();
const coordinateKeys = new Set();
const pointCounts = new Map();
for (const row of spawnPoints) {
	if (!animalById.has(row.animal_id)) errors.push(`${row.animal_id}: unknown spawn animal_id`);
	if (!stages.includes(row.stage_id)) errors.push(`${row.animal_id}: invalid spawn stage`);
	const animalType = animalById.get(row.animal_id);
	const x = number(row.x_local_m, `${row.animal_id} x_local_m`);
	const y = number(row.y_local_m, `${row.animal_id} y_local_m`);
	const z = number(row.z_m, `${row.animal_id} z_m`);
	const weight = number(row.spawn_weight, `${row.animal_id} spawn_weight`);
	number(row.source_x, `${row.animal_id} source_x`);
	number(row.source_y, `${row.animal_id} source_y`);
	number(row.source_z, `${row.animal_id} source_z`);
	if (x < -17.5 || x > 17.5 || y < -17.5 || y > 17.5 || z < 0) {
		errors.push(`${row.stage_id}|${row.animal_id}|${row.point_id}: coordinate outside field`);
	}
	if (weight <= 0) errors.push(`${row.animal_id}|${row.point_id}: weight must be positive`);
	if (row.coordinate_frame !== "gama_field_local_m") {
		errors.push(`${row.animal_id}|${row.point_id}: invalid coordinate frame`);
	}
	if (animalType && row.spawn_surface !== animalType.spawn_surface) {
		errors.push(`${row.stage_id}|${row.animal_id}|${row.point_id}: spawn_surface does not match animal type`);
	}

	const group = `${row.stage_id}|${row.animal_id}`;
	pointCounts.set(group, (pointCounts.get(group) ?? 0) + 1);
	const coordinateKey = `${group}|${row.x_local_m}|${row.y_local_m}|${row.z_m}`;
	if (coordinateKeys.has(coordinateKey)) duplicateCoordinates.add(coordinateKey);
	coordinateKeys.add(coordinateKey);
}
if (duplicateCoordinates.size > 0) {
	errors.push(`spawn_points.csv: ${duplicateCoordinates.size} duplicate coordinates remain`);
}

for (const row of populations) {
	const expected = Number(row.sample_size);
	const actual = pointCounts.get(`${row.stage_id}|${row.animal_id}`) ?? 0;
	if (actual !== expected) {
		errors.push(`${row.stage_id}|${row.animal_id}: sample_size ${expected}, points ${actual}`);
	}
}

for (const row of sources) {
	if (!row.source_id || !row.title) errors.push("data_sources.csv: source_id and title are required");
}

if (sources.some((row) => !row.source_url || row.sampling_date === "not_recorded")) {
	warnings.push("Field source URL/date are not yet recorded; baseline confidence remains low.");
}

const fieldArea = 39 * 39;
const densityScale = 0.15;
for (const stage of stages) {
	const projected = populations
		.filter((row) => row.stage_id === stage && row.presence_status === "observed")
		.reduce(
			(total, row) =>
				total +
				Math.round(
					Number(row.species_density_per_100m2) *
						Number(row.life_stage_fraction) *
						(fieldArea / 100) *
						densityScale,
				),
			0,
		);
	console.log(`${stage}: ${projected} projected agents at density scale ${densityScale}`);
}

for (const warning of warnings) console.warn(`WARNING: ${warning}`);
if (errors.length > 0) {
	for (const error of errors) console.error(`ERROR: ${error}`);
	process.exitCode = 1;
} else {
	console.log(
		`Validated ${animalTypes.length} animal types, ${populations.length} population rows, and ${spawnPoints.length} spawn points.`,
	);
}
