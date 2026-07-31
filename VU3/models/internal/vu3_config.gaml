model vu3_config

global {

	// VU2 CSV paths are relative to a VU2 entry model. Override only the paths
	// and matrices needed when VU2 is imported from the sibling VU3 project.
	string animal_types_csv_path <- "../../VU2/models/animal_types.csv";
	string stage_populations_csv_path <- "../../VU2/models/stage_populations.csv";
	string spawn_points_csv_path <- "../../VU2/models/spawn_points.csv";

	file animal_types_csv_file <- csv_file(animal_types_csv_path, ",");
	file stage_populations_csv_file <- csv_file(stage_populations_csv_path, ",");
	file spawn_points_csv_file <- csv_file(spawn_points_csv_path, ",");

	matrix animal_types_data <- matrix(animal_types_csv_file);
	matrix stage_populations_data <- matrix(stage_populations_csv_file);
	matrix spawn_points_data <- matrix(spawn_points_csv_file);

	// VU3 shows every inherited animal species as a directional triangle.
	// VU2 keeps its original circular markers because its default is false.
	bool animal_markers_are_triangles <- true;

	// ------------------------------------------------------------------------
	// VU3 INTERACTION CONTROL
	// ------------------------------------------------------------------------

	bool vu3_interactions_enabled <- true;

	// A pest must be this close to its nearest rice plant to cause an impact.
	float vu3_pest_attack_radius_m <- 1.60;

	// Direct orthogonal neighbors are 3 m apart in VU2.
	float vu3_neighbor_impact_radius_m <- 3.20;

	// Beneficials only control supported pests inside this local radius.
	float vu3_beneficial_control_radius_m <- 2.20;

	// Prevents all nearby pests from disappearing in one cycle.
	float vu3_beneficial_success_probability <- 0.35;

	// Neighbor plants receive a smaller part of the primary impact.
	float vu3_neighbor_impact_factor <- 0.35;

	// ------------------------------------------------------------------------
	// BROWN PLANTHOPPER EGG LAYING
	// ------------------------------------------------------------------------

	bool vu3_bph_egg_laying_enabled <- true;
	bool create_seeded_bph_eggs <- false;

	// This approximates physical contact with the rice canopy.
	float vu3_bph_egg_laying_radius_m <- 0.50;
	float vu3_bph_egg_laying_probability <- 0.20;
	int vu3_bph_egg_laying_cooldown_cycles <- 30;
	int vu3_bph_max_eggs_per_adult <- 3;
	int vu3_bph_max_eggs_per_rice <- 5;

	int vu3_pests_controlled_this_cycle <- 0;
	int vu3_total_pests_controlled <- 0;
	int vu3_bph_eggs_laid_this_cycle <- 0;
	int vu3_total_bph_eggs_laid <- 0;
}
