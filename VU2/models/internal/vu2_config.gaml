model vu2_config

global {

	// ------------------------------------------------------------------------
	// FIELD SETUP
	// ------------------------------------------------------------------------

	float field_center_x <- 50.0;
	float field_center_y <- 50.0;
	float spacing <- 3.0;

	int nb_cols <- 13;
	int nb_rows <- 13;

	float field_min_x <- field_center_x - ((nb_cols - 1) * spacing) / 2.0;
	float field_max_x <- field_center_x + ((nb_cols - 1) * spacing) / 2.0;
	float field_min_y <- field_center_y - ((nb_rows - 1) * spacing) / 2.0;
	float field_max_y <- field_center_y + ((nb_rows - 1) * spacing) / 2.0;

	// The outer spacing is included when estimating the represented field area.
	float field_width <- nb_cols * spacing;
	float field_length <- nb_rows * spacing;
	float field_area_m2 <- field_width * field_length;

	// Keep the simulation world large enough to contain the field centered at 50,50.
	geometry shape <- envelope(square(110.0));

	// ------------------------------------------------------------------------
	// RICE GROWTH CONTROL
	// ------------------------------------------------------------------------

	string rice_stage <- "vegetative";
	bool auto_progress_rice_stage <- true;
	//cycle per stage
	int stage_duration_cycles <- 300;

	string previous_rice_stage <- "vegetative";

	// ------------------------------------------------------------------------
	// CSV DATA
	// ------------------------------------------------------------------------

	// The legacy animal_data.csv is retained only as migration evidence.
	// Runtime data is separated by responsibility to avoid repeated metadata.
	string animal_types_csv_path <- "animal_types.csv";
	string stage_populations_csv_path <- "stage_populations.csv";
	string spawn_points_csv_path <- "spawn_points.csv";

	file animal_types_csv_file <- csv_file(animal_types_csv_path, ",");
	file stage_populations_csv_file <- csv_file(stage_populations_csv_path, ",");
	file spawn_points_csv_file <- csv_file(spawn_points_csv_path, ",");

	matrix animal_types_data <- matrix(animal_types_csv_file);
	matrix stage_populations_data <- matrix(stage_populations_csv_file);
	matrix spawn_points_data <- matrix(spawn_points_csv_file);

	bool animal_csv_is_valid <- true;

	// Percentage of the density value to instantiate in GAMA.
	// 0.15 means 15% of the calculated population.
	float density_scale <- 0.15;

	// Safety limit for visualization performance.
	int maximum_agents_per_animal_type <- 150;

	// Child models can replace seeded eggs with a runtime reproduction system.
	bool create_seeded_bph_eggs <- true;

	// ------------------------------------------------------------------------
	// IDENTIFICATION DISPLAY
	// ------------------------------------------------------------------------

	bool show_pest_labels <- false;
	bool show_all_animal_labels <- false;
	bool show_rice_labels <- false;
	bool animal_markers_are_triangles <- false;

}
