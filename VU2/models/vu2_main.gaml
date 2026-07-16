model cropguard_rice_field_3d_corrected

// ============================================================================
// CropGuard - Rice Growth and Animal Observation Simulation
// ----------------------------------------------------------------------------
// Functions:
// - Creates a centered 13 x 13 rice field with 3 m spacing.
// - Loads animal information and density from animal_data_gama_optimized.csv.
// - Progresses rice from vegetative -> reproductive -> ripening.
// - Moves animals independently in 3D.
// - Identifies pests visually.
// - Does not simulate crop damage, predation, feeding, or animal interaction.
// ============================================================================

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
	int stage_duration_cycles <- 300;

	string previous_rice_stage <- "vegetative";

	// ------------------------------------------------------------------------
	// CSV DATA
	// ------------------------------------------------------------------------

	string animal_csv_path <- "animal_data.csv";

	// GAMA loads CSV content as a matrix.
	file animal_csv_file <- csv_file(animal_csv_path, ",");
	matrix animal_data <- matrix(animal_csv_file);

	// Percentage of the density value to instantiate in GAMA.
	// 0.15 means 15% of the calculated population.
	float density_scale <- 0.15;

	// Safety limit for visualization performance.
	int maximum_agents_per_animal_type <- 150;

	// ------------------------------------------------------------------------
	// IDENTIFICATION DISPLAY
	// ------------------------------------------------------------------------

	bool show_pest_labels <- false;
	bool show_all_animal_labels <- false;
	bool show_rice_labels <- false;

	list<string> pest_species <- [
		"Brown Planthopper",
		"Golden Apple Snail",
		"Leaf Folder",
		"Leaffolder",
		"Yellow Stem Borer",
		"Rat",
		"Rats",
		"Bird",
		"Birds"
	];

	init {
		do create_field_ground;
		do create_rice_field;
		do create_animals_for_stage(rice_stage);
	}

	// ------------------------------------------------------------------------
	// RICE STAGE PROGRESSION
	// ------------------------------------------------------------------------

	reflex progress_rice_stage when: auto_progress_rice_stage {
		int stage_index <- int(cycle / stage_duration_cycles);

		if stage_index = 0 {
			rice_stage <- "vegetative";
		} else if stage_index = 1 {
			rice_stage <- "reproductive";
		} else {
			rice_stage <- "ripening";
		}

		if rice_stage != previous_rice_stage {
			previous_rice_stage <- rice_stage;

			do clear_rice_field;
			do create_rice_field;

			// The CSV contains different animal records for each rice stage.
			do clear_animals;

			do create_animals_for_stage(rice_stage);
		}
	}

	// ------------------------------------------------------------------------
	// FIELD GENERATION
	// ------------------------------------------------------------------------

	action create_field_ground {
		create field_ground number: 1 {
			location <- {field_center_x, field_center_y, 0.0};
		}
	}

	action clear_rice_field {
		ask vegetative_rice_plant {
			do die;
		}
		ask reproductive_rice_plant {
			do die;
		}
		ask ripening_rice_plant {
			do die;
		}
	}

	action clear_animals {
		ask brown_planthopper { do die; }
		ask leaf_folder { do die; }
		ask lynx_spider { do die; }
		ask trichogramma { do die; }
		ask dragonfly { do die; }
		ask worm { do die; }
		ask frog { do die; }
		ask yellow_stem_borer { do die; }
		ask golden_apple_snail { do die; }
		ask wasp { do die; }
		ask weaver_ant { do die; }
		ask butterfly { do die; }
		ask bee { do die; }
		ask bird { do die; }
		ask rat { do die; }
		ask ladybug { do die; }
		ask duck { do die; }
		ask snake { do die; }
		ask cricket { do die; }
		ask fish { do die; }
	}

	action create_rice_field {
		loop c from: 0 to: nb_cols - 1 {
			loop r from: 0 to: nb_rows - 1 {
				float px <- field_min_x + c * spacing;
				float py <- field_min_y + r * spacing;

				if rice_stage = "vegetative" {
					create vegetative_rice_plant number: 1 {
						plant_id <- "R_" + string(c) + "_" + string(r);
						grid_col <- c;
						grid_row <- r;
						location <- {px, py, 0.0};
					}
				} else if rice_stage = "reproductive" {
					create reproductive_rice_plant number: 1 {
						plant_id <- "R_" + string(c) + "_" + string(r);
						grid_col <- c;
						grid_row <- r;
						location <- {px, py, 0.0};
					}
				} else {
					create ripening_rice_plant number: 1 {
						plant_id <- "R_" + string(c) + "_" + string(r);
						grid_col <- c;
						grid_row <- r;
						location <- {px, py, 0.0};
					}
				}
			}
		}
	}

	// ------------------------------------------------------------------------
	// CSV-BASED ANIMAL GENERATION
	// ------------------------------------------------------------------------

	action create_animals_for_stage(string requested_stage) {

		list<string> processed_animal_ids <- [];

		// Row 0 contains the CSV header, so data starts at row 1.
		loop row_index from: 1 to: animal_data.rows - 1 {

			string row_stage <- string(animal_data[0, row_index]);
			string row_animal_id <- string(animal_data[2, row_index]);

			if row_stage = requested_stage and !(row_animal_id in processed_animal_ids) {

				processed_animal_ids << row_animal_id;

				// Collect all CSV rows belonging to this animal and rice stage.
				list<int> matching_rows <- [];

				loop search_row from: 1 to: animal_data.rows - 1 {
					if string(animal_data[0, search_row]) = requested_stage
						and string(animal_data[2, search_row]) = row_animal_id {

						matching_rows << search_row;
					}
				}

				if !empty(matching_rows) {

					int first_row <- first(matching_rows);
					float density <- float(animal_data[8, first_row]);

					int desired_count <- int(
						round(density * field_area_m2 / 100.0 * density_scale)
					);

					desired_count <- max([
						1,
						min([maximum_agents_per_animal_type, desired_count])
					]);

					string species_value <- string(animal_data[4, first_row]);

					if species_value = "Brown Planthopper" {
						create brown_planthopper number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Leaf Folder" {
						create leaf_folder number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Lynx Spider" {
						create lynx_spider number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Trichogramma" {
						create trichogramma number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Dragonfly" {
						create dragonfly number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Worm" {
						create worm number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Frog" {
						create frog number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Yellow Stem Borer" {
						create yellow_stem_borer number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Golden Apple Snail" {
						create golden_apple_snail number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Wasp" {
						create wasp number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Weaver Ant" {
						create weaver_ant number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Butterfly" {
						create butterfly number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Bee" {
						create bee number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Bird" {
						create bird number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Rat" {
						create rat number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Ladybug" {
						create ladybug number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Duck" {
						create duck number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Snake" {
						create snake number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Cricket" {
						create cricket number: desired_count { do setup_from_csv_rows(matching_rows); }
					} else if species_value = "Fish" {
						create fish number: desired_count { do setup_from_csv_rows(matching_rows); }
					}
				}
			}
		}
	}

}

// ============================================================================
// FIELD GROUND
// ============================================================================

species field_ground {

	aspect default {
		draw rectangle(field_width + spacing, field_length + spacing)
			at: {location.x, location.y, -0.10}
			color: rgb(105, 145, 75)
			border: rgb(70, 100, 50);
	}
}

// ============================================================================
// RICE PLANTS
// ============================================================================

species vegetative_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.00;
	float canopy_size <- 0.38;

	aspect default {
		draw cylinder(0.07, plant_height)
			at: {location.x, location.y, plant_height / 2.0}
			color: rgb(55, 165, 65);

		draw sphere(canopy_size)
			at: {location.x, location.y, plant_height * 0.70}
			color: rgb(55, 165, 65);

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "vegetative"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}
}

species reproductive_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.45;
	float canopy_size <- 0.48;

	aspect default {
		draw cylinder(0.07, plant_height)
			at: {location.x, location.y, plant_height / 2.0}
			color: rgb(75, 155, 60);

		draw sphere(canopy_size)
			at: {location.x, location.y, plant_height * 0.70}
			color: rgb(75, 155, 60);

		draw sphere(0.14)
			at: {location.x, location.y, plant_height + 0.08}
			color: rgb(190, 205, 90);

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "reproductive"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}
}

species ripening_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.70;
	float canopy_size <- 0.52;

	aspect default {
		draw cylinder(0.07, plant_height)
			at: {location.x, location.y, plant_height / 2.0}
			color: rgb(145, 160, 55);

		draw sphere(canopy_size)
			at: {location.x, location.y, plant_height * 0.70}
			color: rgb(145, 160, 55);

		draw sphere(0.14)
			at: {location.x, location.y, plant_height + 0.08}
			color: rgb(225, 185, 55);

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "ripening"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}
}

// ============================================================================
// ANIMALS
// ============================================================================

species animal_template skills: [moving] {

	string stage_id;
	string stage_name;
	string animal_id;
	string animal_name;
	string species_name;
	string life_stage;
	string prefab_name;
	string prefab_path;

	float density_per_100m2 <- 0.0;

	bool is_pest <- false;
	string movement_mode <- "ground";

	point movement_destination;
	int destination_timer <- 0;
	float movement_speed <- 0.08;

	action setup_from_csv_rows(list<int> matching_rows) {

		int selected_row <- one_of(matching_rows);

		stage_id <- string(animal_data[0, selected_row]);
		stage_name <- string(animal_data[1, selected_row]);
		animal_id <- string(animal_data[2, selected_row]);
		animal_name <- string(animal_data[3, selected_row]);
		species_name <- string(animal_data[4, selected_row]);
		life_stage <- string(animal_data[5, selected_row]);
		prefab_name <- string(animal_data[6, selected_row]);
		prefab_path <- string(animal_data[7, selected_row]);
		density_per_100m2 <- float(animal_data[8, selected_row]);

		float csv_x <- float(animal_data[10, selected_row]);
		float csv_y <- float(animal_data[11, selected_row]);
		float csv_z <- float(animal_data[12, selected_row]);

		is_pest <- species_name in pest_species;
		movement_mode <- get_movement_mode(species_name, life_stage);

		float local_x <- max([
			-field_width / 2.0,
			min([field_width / 2.0, csv_x])
		]);

		float local_y <- max([
			-field_length / 2.0,
			min([field_length / 2.0, csv_y])
		]);

		float start_z <- get_start_height(movement_mode, csv_z);

		location <- {
			max([
				field_min_x,
				min([field_max_x, field_center_x + local_x + rnd(-0.4, 0.4)])
			]),
			max([
				field_min_y,
				min([field_max_y, field_center_y + local_y + rnd(-0.4, 0.4)])
			]),
			start_z
		};

		movement_speed <- get_movement_speed(movement_mode);
		do choose_new_destination;
	}

	string get_movement_mode(string species_value, string life_value) {

		string name_lower <- lower_case(species_value);
		string life_lower <- lower_case(life_value);

		// Eggs remain stationary.
		if life_lower contains "egg" {
			return "stationary";
		}

		if name_lower contains "bird"
			or name_lower contains "bee"
			or name_lower contains "butterfly"
			or name_lower contains "dragonfly"
			or name_lower contains "wasp"
			or name_lower contains "trichogramma" {

			return "fly";
		}

		if name_lower contains "fish"
			or name_lower contains "duck" {

			return "water";
		}

		if name_lower contains "planthopper"
			or name_lower contains "leaf"
			or name_lower contains "stem borer"
			or name_lower contains "ladybug"
			or name_lower contains "spider"
			or name_lower contains "cricket" {

			return "plant";
		}

		return "ground";
	}

	float get_start_height(string move_mode, float csv_z) {

		if move_mode = "fly" {
			return max([1.5, min([4.0, abs(csv_z) + 1.0])]);
		}

		if move_mode = "plant" {
			return max([0.25, min([1.8, abs(csv_z)])]);
		}

		if move_mode = "water" {
			return 0.10;
		}

		if move_mode = "stationary" {
			return max([0.15, min([1.5, abs(csv_z)])]);
		}

		return max([0.08, min([0.35, abs(csv_z)])]);
	}

	float get_movement_speed(string move_mode) {

		if move_mode = "fly" {
			return rnd(0.20, 0.50);
		}

		if move_mode = "plant" {
			return rnd(0.05, 0.14);
		}

		if move_mode = "water" {
			return rnd(0.06, 0.18);
		}

		if move_mode = "stationary" {
			return 0.0;
		}

		return rnd(0.03, 0.10);
	}

	action choose_new_destination {

		float destination_z <- location.z;

		if movement_mode = "fly" {
			destination_z <- rnd(1.2, 4.0);

		} else if movement_mode = "plant" {
			destination_z <- rnd(0.25, 1.70);

		} else if movement_mode = "water" {
			destination_z <- 0.10;

		} else if movement_mode = "ground" {
			destination_z <- rnd(0.08, 0.30);
		}

		movement_destination <- {
			rnd(field_min_x, field_max_x),
			rnd(field_min_y, field_max_y),
			destination_z
		};

		destination_timer <- rnd(20, 80);
	}

	reflex move_independently {

		// Egg records and other stationary records do not move.
		if movement_mode != "stationary" {

			destination_timer <- destination_timer - 1;

			if destination_timer <= 0
				or self distance_to movement_destination < 0.30 {

				do choose_new_destination;
			}

			do goto target: movement_destination speed: movement_speed;
		}
	}

	aspect default {

		rgb animal_color <- #cyan;

		if is_pest {
			animal_color <- #red;
		} else if movement_mode = "fly" {
			animal_color <- #yellow;
		} else if movement_mode = "water" {
			animal_color <- #blue;
		}

		float body_size <- 0.18;

		if movement_mode = "fly" {
			body_size <- 0.22;
		} else if movement_mode = "water" {
			body_size <- 0.28;
		} else if movement_mode = "stationary" {
			body_size <- 0.12;
		}

		draw sphere(body_size)
			at: location
			color: animal_color;

		bool display_label <- show_all_animal_labels
			or (show_pest_labels and is_pest);

		if display_label {
			string label_text <- species_name + " - " + life_stage;

			if is_pest {
				label_text <- "PEST: " + label_text;
			}

			draw label_text
				at: {
					location.x,
					location.y,
					location.z + body_size + 0.20
				}
				color: is_pest ? #red : #black
				size: 0.30;
		}
	}
}

species brown_planthopper parent: animal_template {
}

species leaf_folder parent: animal_template {
}

species lynx_spider parent: animal_template {
}

species trichogramma parent: animal_template {
}

species dragonfly parent: animal_template {
}

species worm parent: animal_template {
}

species frog parent: animal_template {
}

species yellow_stem_borer parent: animal_template {
}

species golden_apple_snail parent: animal_template {
}

species wasp parent: animal_template {
}

species weaver_ant parent: animal_template {
}

species butterfly parent: animal_template {
}

species bee parent: animal_template {
}

species bird parent: animal_template {
}

species rat parent: animal_template {
}

species ladybug parent: animal_template {
}

species duck parent: animal_template {
}

species snake parent: animal_template {
}

species cricket parent: animal_template {
}

species fish parent: animal_template {
}

// ============================================================================
// GUI EXPERIMENT
// ============================================================================

experiment vu2 type: gui {

	parameter "Rice growth stage"
		var: rice_stage
		among: ["vegetative", "reproductive", "ripening"];

	parameter "Automatically progress rice stage"
		var: auto_progress_rice_stage;

	parameter "Stage duration in cycles"
		var: stage_duration_cycles
		min: 30
		max: 2000
		step: 10;

	parameter "Animal density scale"
		var: density_scale
		min: 0.01
		max: 1.0
		step: 0.01;

	parameter "Maximum agents per animal type"
		var: maximum_agents_per_animal_type
		min: 1
		max: 1000
		step: 10;

	parameter "Show pest labels"
		var: show_pest_labels;

	parameter "Show all animal labels"
		var: show_all_animal_labels;

	parameter "Show rice stage label"
		var: show_rice_labels;

	output {

		display "VU2"
			type: 3d
			background: rgb(210, 230, 240) {

			species field_ground aspect: default;
			species vegetative_rice_plant aspect: default;
			species reproductive_rice_plant aspect: default;
			species ripening_rice_plant aspect: default;
			species brown_planthopper aspect: default;
			species leaf_folder aspect: default;
			species lynx_spider aspect: default;
			species trichogramma aspect: default;
			species dragonfly aspect: default;
			species worm aspect: default;
			species frog aspect: default;
			species yellow_stem_borer aspect: default;
			species golden_apple_snail aspect: default;
			species wasp aspect: default;
			species weaver_ant aspect: default;
			species butterfly aspect: default;
			species bee aspect: default;
			species bird aspect: default;
			species rat aspect: default;
			species ladybug aspect: default;
			species duck aspect: default;
			species snake aspect: default;
			species cricket aspect: default;
			species fish aspect: default;
		}

		monitor "Rice stage"
			value: rice_stage;

		monitor "Rice plants"
			value: length(vegetative_rice_plant)
				+ length(reproductive_rice_plant)
				+ length(ripening_rice_plant);

		monitor "Animal agents"
			value: length(brown_planthopper)
				+ length(leaf_folder)
				+ length(lynx_spider)
				+ length(trichogramma)
				+ length(dragonfly)
				+ length(worm)
				+ length(frog)
				+ length(yellow_stem_borer)
				+ length(golden_apple_snail)
				+ length(wasp)
				+ length(weaver_ant)
				+ length(butterfly)
				+ length(bee)
				+ length(bird)
				+ length(rat)
				+ length(ladybug)
				+ length(duck)
				+ length(snake)
				+ length(cricket)
				+ length(fish);

		monitor "Pest agents"
			value: length(brown_planthopper where (each.is_pest))
				+ length(leaf_folder where (each.is_pest))
				+ length(lynx_spider where (each.is_pest))
				+ length(trichogramma where (each.is_pest))
				+ length(dragonfly where (each.is_pest))
				+ length(worm where (each.is_pest))
				+ length(frog where (each.is_pest))
				+ length(yellow_stem_borer where (each.is_pest))
				+ length(golden_apple_snail where (each.is_pest))
				+ length(wasp where (each.is_pest))
				+ length(weaver_ant where (each.is_pest))
				+ length(butterfly where (each.is_pest))
				+ length(bee where (each.is_pest))
				+ length(bird where (each.is_pest))
				+ length(rat where (each.is_pest))
				+ length(ladybug where (each.is_pest))
				+ length(duck where (each.is_pest))
				+ length(snake where (each.is_pest))
				+ length(cricket where (each.is_pest))
				+ length(fish where (each.is_pest));

		monitor "CSV rows"
			value: animal_data.rows;

		monitor "Field area m2"
			value: field_area_m2;
	}
}
