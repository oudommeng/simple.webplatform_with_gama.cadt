model cropguard_vu2_main_3D_complete

// AUTO-GENERATED STANDALONE MODEL.
// Contains all VU2 simulation logic and has no GAML imports.
// External runtime assets: CSV files in models/ and clean OBJ/MTL files in ../fbx/gama/gama/.

global {
	// CONFIG
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
	// WATER LEVEL CONTROL
	// ------------------------------------------------------------------------

	float vegetative_water_level <- 0.18;
	float reproductive_water_level <- 0.12;
	float ripening_water_level <- 0.03;
	float water_level <- vegetative_water_level;
	float target_water_level <- vegetative_water_level;
	float water_level_adjustment_rate <- 0.015;

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
	bool pest_damage_relation_csv_is_valid <- true;

	// Percentage of the density value to instantiate in GAMA.
	// 0.15 means 15% of the calculated population.
	float density_scale <- 0.15;

	// Safety limit for visualization performance.
	int maximum_agents_per_animal_type <- 150;

	// Multiplies CSV speed values so animal movement remains visually realistic.
	float animal_movement_speed_scale <- 0.10;
	float max_ground_speed_m_per_cycle <- 0.006;
	float max_plant_speed_m_per_cycle <- 0.010;
	float max_water_speed_m_per_cycle <- 0.012;
	float max_flying_speed_m_per_cycle <- 0.025;

	// Interaction radius for predefined pest damage species.
	float default_pest_impact_radius_m <- 0.75;
	bool enable_pest_impacts <- true;
	int pest_impact_update_interval_cycles <- 1;
	int maximum_pest_impacts <- 250;

	// Child models can replace seeded eggs with a runtime reproduction system.
	bool create_seeded_bph_eggs <- true;

	// ------------------------------------------------------------------------
	// IDENTIFICATION DISPLAY
	// ------------------------------------------------------------------------

	bool show_pest_labels <- false;
	bool show_pest_damage_labels <- true;
	bool show_all_animal_labels <- false;
	bool show_rice_labels <- false;
	bool animal_markers_are_triangles <- false;

	// FIELD
action create_field_ground {
		create field_ground number: 1 {
			location <- {field_center_x, field_center_y, 0.0};
		}
	}

	// WATER
float water_level_for_stage(string stage) {
		if stage = "vegetative" {
			return vegetative_water_level;
		}

		if stage = "reproductive" {
			return reproductive_water_level;
		}

		return ripening_water_level;
	}

	action update_water_target_for_stage {
		target_water_level <- water_level_for_stage(rice_stage);
	}

	action create_water_surface {
		do update_water_target_for_stage;

		if empty(water) {
			create water number: 1 {
				location <- {field_center_x, field_center_y, water_level};
			}
		}
	}

	reflex adjust_water_level {
		do update_water_target_for_stage;

		float level_delta <- target_water_level - water_level;

		if abs(level_delta) <= water_level_adjustment_rate {
			water_level <- target_water_level;
		} else if level_delta > 0.0 {
			water_level <- water_level + water_level_adjustment_rate;
		} else {
			water_level <- water_level - water_level_adjustment_rate;
		}

		ask water {
			location <- {field_center_x, field_center_y, water_level};
			depth <- water_level;
		}
	}

	// RICE
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

	// ANIMALS
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

	int current_animal_count(string row_animal_id, string gama_species_value) {
		if gama_species_value = "brown_planthopper" { return length(brown_planthopper where (each.animal_id = row_animal_id)); }
		if gama_species_value = "leaf_folder" { return length(leaf_folder where (each.animal_id = row_animal_id)); }
		if gama_species_value = "lynx_spider" { return length(lynx_spider where (each.animal_id = row_animal_id)); }
		if gama_species_value = "trichogramma" { return length(trichogramma where (each.animal_id = row_animal_id)); }
		if gama_species_value = "dragonfly" { return length(dragonfly where (each.animal_id = row_animal_id)); }
		if gama_species_value = "worm" { return length(worm where (each.animal_id = row_animal_id)); }
		if gama_species_value = "frog" { return length(frog where (each.animal_id = row_animal_id)); }
		if gama_species_value = "yellow_stem_borer" { return length(yellow_stem_borer where (each.animal_id = row_animal_id)); }
		if gama_species_value = "golden_apple_snail" { return length(golden_apple_snail where (each.animal_id = row_animal_id)); }
		if gama_species_value = "wasp" { return length(wasp where (each.animal_id = row_animal_id)); }
		if gama_species_value = "weaver_ant" { return length(weaver_ant where (each.animal_id = row_animal_id)); }
		if gama_species_value = "butterfly" { return length(butterfly where (each.animal_id = row_animal_id)); }
		if gama_species_value = "bee" { return length(bee where (each.animal_id = row_animal_id)); }
		if gama_species_value = "bird" { return length(bird where (each.animal_id = row_animal_id)); }
		if gama_species_value = "rat" { return length(rat where (each.animal_id = row_animal_id)); }
		if gama_species_value = "ladybug" { return length(ladybug where (each.animal_id = row_animal_id)); }
		if gama_species_value = "duck" { return length(duck where (each.animal_id = row_animal_id)); }
		if gama_species_value = "snake" { return length(snake where (each.animal_id = row_animal_id)); }
		if gama_species_value = "cricket" { return length(cricket where (each.animal_id = row_animal_id)); }
		if gama_species_value = "fish" { return length(fish where (each.animal_id = row_animal_id)); }

		return 0;
	}

	action update_existing_animals_for_population(
		string row_animal_id,
		string gama_species_value,
		int population_row
	) {
		if gama_species_value = "brown_planthopper" { ask brown_planthopper where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "leaf_folder" { ask leaf_folder where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "lynx_spider" { ask lynx_spider where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "trichogramma" { ask trichogramma where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "dragonfly" { ask dragonfly where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "worm" { ask worm where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "frog" { ask frog where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "yellow_stem_borer" { ask yellow_stem_borer where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "golden_apple_snail" { ask golden_apple_snail where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "wasp" { ask wasp where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "weaver_ant" { ask weaver_ant where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "butterfly" { ask butterfly where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "bee" { ask bee where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "bird" { ask bird where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "rat" { ask rat where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "ladybug" { ask ladybug where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "duck" { ask duck where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "snake" { ask snake where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "cricket" { ask cricket where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "fish" { ask fish where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
	}

	action create_animals_for_stage(string requested_stage) {

		string effective_stage <- requested_stage;

		if !animal_csv_is_valid {
			write "Animal CSV validation failed. No animals will be created.";
			effective_stage <- "invalid";
		}

		// Each population row represents one animal life stage. Row 0 is the header.
		loop population_row from: 1 to: stage_populations_data.rows - 1 {
			string row_stage <- string(stage_populations_data[0, population_row]);
			string presence_status <- string(stage_populations_data[8, population_row]);

			if row_stage = effective_stage and presence_status = "observed" {
				string row_animal_id <- string(stage_populations_data[2, population_row]);
				int type_row <- find_animal_type_row(row_animal_id);

				bool should_create_type <- row_animal_id != "brown_planthopper_eggs"
					or create_seeded_bph_eggs;

				if should_create_type
					and type_row > 0
					and string(animal_types_data[15, type_row]) = "true" {

					list<int> matching_spawn_rows <- [];

					// GAMA recognizes the fully populated spawn header, so row 0 is data.
					loop spawn_row from: 0 to: spawn_points_data.rows - 1 {
						if string(spawn_points_data[0, spawn_row]) = effective_stage
							and string(spawn_points_data[1, spawn_row]) = row_animal_id {

							matching_spawn_rows << spawn_row;
						}
					}

					float species_density <- float(stage_populations_data[4, population_row]);
					float life_stage_fraction <- float(stage_populations_data[5, population_row]);
					int desired_count <- int(round(
						species_density
						* life_stage_fraction
						* field_area_m2 / 100.0
						* density_scale
					));

					desired_count <- min([maximum_agents_per_animal_type, desired_count]);

					if desired_count > 0 and !empty(matching_spawn_rows) {
						string gama_species_value <- string(animal_types_data[7, type_row]);
						int current_count <- current_animal_count(row_animal_id, gama_species_value);
						int additional_count <- max([0, desired_count - current_count]);

						do update_existing_animals_for_population(
							row_animal_id,
							gama_species_value,
							population_row
						);

						if additional_count > 0 {
							if gama_species_value = "brown_planthopper" {
								create brown_planthopper number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "leaf_folder" {
								create leaf_folder number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "lynx_spider" {
								create lynx_spider number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "trichogramma" {
								create trichogramma number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "dragonfly" {
								create dragonfly number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "worm" {
								create worm number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "frog" {
								create frog number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "yellow_stem_borer" {
								create yellow_stem_borer number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "golden_apple_snail" {
								create golden_apple_snail number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "wasp" {
								create wasp number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "weaver_ant" {
								create weaver_ant number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "butterfly" {
								create butterfly number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "bee" {
								create bee number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "bird" {
								create bird number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "rat" {
								create rat number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "ladybug" {
								create ladybug number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "duck" {
								create duck number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "snake" {
								create snake number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "cricket" {
								create cricket number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "fish" {
								create fish number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							}
						}
					}
				}
			}
		}
	}

	int find_animal_type_row(string animal_id_value) {
		loop type_row from: 1 to: animal_types_data.rows - 1 {
			if string(animal_types_data[0, type_row]) = animal_id_value {
				return type_row;
			}
		}
		return -1;
	}

	action validate_animal_csv_data {
		animal_csv_is_valid <- true;

		if animal_types_data.rows <= 1 {
			write "animal_types.csv has no data rows.";
			animal_csv_is_valid <- false;
		}

		if stage_populations_data.rows <= 1 {
			write "stage_populations.csv has no data rows.";
			animal_csv_is_valid <- false;
		}

		if spawn_points_data.rows <= 1 {
			write "spawn_points.csv has no data rows.";
			animal_csv_is_valid <- false;
		}

		if string(animal_types_data[0, 0]) != "animal_id"
			or string(stage_populations_data[0, 0]) != "stage_id"
			or !(string(spawn_points_data[0, 0]) in ["vegetative", "reproductive", "ripening"])
			or string(spawn_points_data[6, 0]) != "gama_field_local_m" {

			write "Animal CSV headers do not match the normalized schema.";
			animal_csv_is_valid <- false;
		}

		loop population_row from: 1 to: stage_populations_data.rows - 1 {
			string row_stage <- string(stage_populations_data[0, population_row]);
			string row_animal_id <- string(stage_populations_data[2, population_row]);
			float species_density <- float(stage_populations_data[4, population_row]);
			float life_stage_fraction <- float(stage_populations_data[5, population_row]);
			string presence_status <- string(stage_populations_data[8, population_row]);

			if !(row_stage in ["vegetative", "reproductive", "ripening"]) {
				write "Invalid stage in stage_populations.csv: " + row_stage;
				animal_csv_is_valid <- false;
			}

			if find_animal_type_row(row_animal_id) <= 0 {
				write "Unknown animal_id in stage_populations.csv: " + row_animal_id;
				animal_csv_is_valid <- false;
			}

			if !(presence_status in ["observed", "absent", "not_sampled"]) {
				write "Invalid presence_status in stage_populations.csv: " + presence_status;
				animal_csv_is_valid <- false;
			}

			if species_density < 0.0 or life_stage_fraction < 0.0 or life_stage_fraction > 1.0 {
				write "Invalid density or life-stage fraction for " + row_stage + "|" + row_animal_id;
				animal_csv_is_valid <- false;
			}

			if presence_status != "observed"
				and (species_density != 0.0 or life_stage_fraction != 0.0) {

				write "Non-observed population rows must have zero density and fraction: " + row_stage + "|" + row_animal_id;
				animal_csv_is_valid <- false;
			}
		}

		loop spawn_row from: 0 to: spawn_points_data.rows - 1 {
			string spawn_stage <- string(spawn_points_data[0, spawn_row]);
			string spawn_animal_id <- string(spawn_points_data[1, spawn_row]);
			float local_x <- float(spawn_points_data[3, spawn_row]);
			float local_y <- float(spawn_points_data[4, spawn_row]);
			float local_z <- float(spawn_points_data[5, spawn_row]);
			float spawn_weight <- float(spawn_points_data[8, spawn_row]);

			if !(spawn_stage in ["vegetative", "reproductive", "ripening"]) {
				write "Invalid stage in spawn_points.csv: " + spawn_stage;
				animal_csv_is_valid <- false;
			}

			if find_animal_type_row(spawn_animal_id) <= 0 {
				write "Unknown animal_id in spawn_points.csv: " + spawn_animal_id;
				animal_csv_is_valid <- false;
			}

			if local_x < -17.5 or local_x > 17.5 or local_y < -17.5 or local_y > 17.5 or local_z < 0.0 {
				write "Spawn point outside local field bounds: " + spawn_stage + "|" + spawn_animal_id;
				animal_csv_is_valid <- false;
			}

			if spawn_weight <= 0.0 {
				write "Spawn weight must be positive: " + spawn_stage + "|" + spawn_animal_id;
				animal_csv_is_valid <- false;
			}
		}
	}

	// DAMAGE
int current_pest_impact_creations <- 0;

	action validate_pest_damage_relation_data {
		// Damage species are predefined in this GAML file.
		pest_damage_relation_csv_is_valid <- true;
	}

	int pest_impact_count {
		return length(bph_vegetative_damage)
			+ length(bph_reproductive_damage)
			+ length(bph_ripening_damage)
			+ length(gas_vegetative_damage)
			+ length(gas_reproductive_damage)
			+ length(ysb_vegetative_damage)
			+ length(ysb_reproductive_damage)
			+ length(lf_vegetative_damage)
			+ length(lf_reproductive_damage)
			+ length(lf_ripening_damage)
			+ length(rat_ripening_damage)
			+ length(bird_ripening_damage);
	}

	action clear_pest_impacts {
		ask bph_vegetative_damage { do die; }
		ask bph_reproductive_damage { do die; }
		ask bph_ripening_damage { do die; }
		ask gas_vegetative_damage { do die; }
		ask gas_reproductive_damage { do die; }
		ask ysb_vegetative_damage { do die; }
		ask ysb_reproductive_damage { do die; }
		ask lf_vegetative_damage { do die; }
		ask lf_reproductive_damage { do die; }
		ask lf_ripening_damage { do die; }
		ask rat_ripening_damage { do die; }
		ask bird_ripening_damage { do die; }
	}

	reflex create_pest_impacts when: enable_pest_impacts
		and cycle mod pest_impact_update_interval_cycles = 0 {

		do clear_pest_impacts;
		current_pest_impact_creations <- 0;

		if rice_stage = "vegetative" {
			ask vegetative_rice_plant {
				string rice_id <- plant_id;
				point rice_location <- location;
				int bph_pressure <- length(brown_planthopper where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int gas_pressure <- length(golden_apple_snail where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int ysb_pressure <- length(yellow_stem_borer where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int lf_pressure <- length(leaf_folder where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));

				pest_pressure_count <- bph_pressure + gas_pressure + ysb_pressure + lf_pressure;
				pest_damage_score <- float(pest_pressure_count);
				has_pest_damage <- pest_pressure_count > 0;
				int total_pest_pressure <- pest_pressure_count;

				string dominant_pest_name <- "";
				string dominant_damage_prefab <- "";
				int dominant_pressure <- 0;

				if bph_pressure > dominant_pressure {
					dominant_pest_name <- "Brown Planthopper";
					dominant_damage_prefab <- "BPH_Vegetative_Severe.prefab";
					dominant_pressure <- bph_pressure;
				}
				if gas_pressure > dominant_pressure {
					dominant_pest_name <- "Golden Apple Snail";
					dominant_damage_prefab <- "GAS_Vegetative_Severe.prefab";
					dominant_pressure <- gas_pressure;
				}
				if ysb_pressure > dominant_pressure {
					dominant_pest_name <- "Yellow Stem Borer";
					dominant_damage_prefab <- "YSB_Vegetative_Severe.prefab";
					dominant_pressure <- ysb_pressure;
				}
				if lf_pressure > dominant_pressure {
					dominant_pest_name <- "Leaf Folder";
					dominant_damage_prefab <- "LF_Vegetative_Severe.prefab";
					dominant_pressure <- lf_pressure;
				}

				if total_pest_pressure > 0 {
					if current_pest_impact_creations < maximum_pest_impacts {
						if dominant_damage_prefab = "BPH_Vegetative_Severe.prefab" {
							create bph_vegetative_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "GAS_Vegetative_Severe.prefab" {
							create gas_vegetative_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "YSB_Vegetative_Severe.prefab" {
							create ysb_vegetative_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "LF_Vegetative_Severe.prefab" {
							create lf_vegetative_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						}
						current_pest_impact_creations <- current_pest_impact_creations + 1;
					}
				}
			}
		} else if rice_stage = "reproductive" {
			ask reproductive_rice_plant {
				string rice_id <- plant_id;
				point rice_location <- location;
				int bph_pressure <- length(brown_planthopper where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int gas_pressure <- length(golden_apple_snail where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int ysb_pressure <- length(yellow_stem_borer where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int lf_pressure <- length(leaf_folder where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));

				pest_pressure_count <- bph_pressure + gas_pressure + ysb_pressure + lf_pressure;
				pest_damage_score <- float(pest_pressure_count);
				has_pest_damage <- pest_pressure_count > 0;
				int total_pest_pressure <- pest_pressure_count;

				string dominant_pest_name <- "";
				string dominant_damage_prefab <- "";
				int dominant_pressure <- 0;

				if bph_pressure > dominant_pressure {
					dominant_pest_name <- "Brown Planthopper";
					dominant_damage_prefab <- "BPH_Reproductive_Severe.prefab";
					dominant_pressure <- bph_pressure;
				}
				if gas_pressure > dominant_pressure {
					dominant_pest_name <- "Golden Apple Snail";
					dominant_damage_prefab <- "GAS_Reproductive_Severe.prefab";
					dominant_pressure <- gas_pressure;
				}
				if ysb_pressure > dominant_pressure {
					dominant_pest_name <- "Yellow Stem Borer";
					dominant_damage_prefab <- "YSB_Reproductive_Severe.prefab";
					dominant_pressure <- ysb_pressure;
				}
				if lf_pressure > dominant_pressure {
					dominant_pest_name <- "Leaf Folder";
					dominant_damage_prefab <- "LF_Reproductive_Severe.prefab";
					dominant_pressure <- lf_pressure;
				}

				if total_pest_pressure > 0 {
					if current_pest_impact_creations < maximum_pest_impacts {
						if dominant_damage_prefab = "BPH_Reproductive_Severe.prefab" {
							create bph_reproductive_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "GAS_Reproductive_Severe.prefab" {
							create gas_reproductive_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "YSB_Reproductive_Severe.prefab" {
							create ysb_reproductive_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "LF_Reproductive_Severe.prefab" {
							create lf_reproductive_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						}
						current_pest_impact_creations <- current_pest_impact_creations + 1;
					}
				}
			}
		} else {
			ask ripening_rice_plant {
				string rice_id <- plant_id;
				point rice_location <- location;
				int bph_pressure <- length(brown_planthopper where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int lf_pressure <- length(leaf_folder where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int rat_pressure <- length(rat where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));
				int bird_pressure <- length(bird where (
					(each.location distance_to rice_location) <= default_pest_impact_radius_m
				));

				pest_pressure_count <- bph_pressure + lf_pressure + rat_pressure + bird_pressure;
				pest_damage_score <- float(pest_pressure_count);
				has_pest_damage <- pest_pressure_count > 0;
				int total_pest_pressure <- pest_pressure_count;

				string dominant_pest_name <- "";
				string dominant_damage_prefab <- "";
				int dominant_pressure <- 0;

				if bph_pressure > dominant_pressure {
					dominant_pest_name <- "Brown Planthopper";
					dominant_damage_prefab <- "BPH_Ripening_Severe.prefab";
					dominant_pressure <- bph_pressure;
				}
				if lf_pressure > dominant_pressure {
					dominant_pest_name <- "Leaf Folder";
					dominant_damage_prefab <- "LF_Ripening_Severe.prefab";
					dominant_pressure <- lf_pressure;
				}
				if rat_pressure > dominant_pressure {
					dominant_pest_name <- "Rat";
					dominant_damage_prefab <- "R_Ripening.prefab";
					dominant_pressure <- rat_pressure;
				}
				if bird_pressure > dominant_pressure {
					dominant_pest_name <- "Bird";
					dominant_damage_prefab <- "B_Ripening.prefab";
					dominant_pressure <- bird_pressure;
				}

				if total_pest_pressure > 0 {
					if current_pest_impact_creations < maximum_pest_impacts {
						if dominant_damage_prefab = "BPH_Ripening_Severe.prefab" {
							create bph_ripening_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "LF_Ripening_Severe.prefab" {
							create lf_ripening_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "R_Ripening.prefab" {
							create rat_ripening_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						} else if dominant_damage_prefab = "B_Ripening.prefab" {
							create bird_ripening_damage number: 1 {
								do setup_pest_impact("aggregated", dominant_pest_name, "multiple", rice_id, dominant_damage_prefab, rice_location, total_pest_pressure);
							}
						}
						current_pest_impact_creations <- current_pest_impact_creations + 1;
					}
				}
			}
		}
	}

	// ENTRY
init {
		do validate_animal_csv_data;
		do validate_pest_damage_relation_data;
		do create_field_ground;
		do create_water_surface;
		do create_rice_field;
		do create_animals_for_stage(rice_stage);
	}

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
			do update_water_target_for_stage;
			do clear_pest_impacts;
			do clear_rice_field;
			do create_rice_field;
			do create_animals_for_stage(rice_stage);
		}
	}
}

species field_ground {

	aspect default {
		draw rectangle(field_width + spacing, field_length + spacing)
			at: {location.x, location.y, -0.10}
			color: rgb(105, 145, 75)
			border: rgb(70, 100, 50);
	}
}

species water {

	float depth <- water_level;

	aspect default {
		draw rectangle(field_width + spacing, field_length + spacing)
			at: {location.x, location.y, depth}
			color: rgb(rgb(55, 135, 210), 0.40)
			border: rgb(35, 95, 165);
	}
}

species vegetative_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.00;
	float canopy_size <- 0.38;
	int pest_pressure_count <- 0;
	float pest_damage_score <- 0.0;
	bool has_pest_damage <- false;

	aspect default {
		if !has_pest_damage {
			draw cylinder(0.07, plant_height)
				at: {location.x, location.y, plant_height / 2.0}
				color: rgb(55, 165, 65);

			draw sphere(canopy_size)
				at: {location.x, location.y, plant_height * 0.70}
				color: rgb(55, 165, 65);
		}

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "vegetative"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}

	aspect mesh3d {
		if !has_pest_damage {
			draw obj_file("../fbx/gama/Plants/RicePlant_Vegetative.gama.obj", 90::{-1, 0, 0})
				size: 1.60
				at: location
				color: rgb(55, 165, 65);
		}
	}
}

species reproductive_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.45;
	float canopy_size <- 0.48;
	int pest_pressure_count <- 0;
	float pest_damage_score <- 0.0;
	bool has_pest_damage <- false;

	aspect default {
		if !has_pest_damage {
			draw cylinder(0.07, plant_height)
				at: {location.x, location.y, plant_height / 2.0}
				color: rgb(75, 155, 60);

			draw sphere(canopy_size)
				at: {location.x, location.y, plant_height * 0.70}
				color: rgb(75, 155, 60);

			draw sphere(0.14)
				at: {location.x, location.y, plant_height + 0.08}
				color: rgb(190, 205, 90);
		}

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "reproductive"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}

	aspect mesh3d {
		if !has_pest_damage {
			draw obj_file("../fbx/gama/Plants/RicePlant_Reproductive.gama.obj", 90::{-1, 0, 0})
				size: 1.95
				at: location
				color: rgb(105, 165, 60);
		}
	}
}

species ripening_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.70;
	float canopy_size <- 0.52;
	int pest_pressure_count <- 0;
	float pest_damage_score <- 0.0;
	bool has_pest_damage <- false;

	aspect default {
		if !has_pest_damage {
			draw cylinder(0.07, plant_height)
				at: {location.x, location.y, plant_height / 2.0}
				color: rgb(145, 160, 55);

			draw sphere(canopy_size)
				at: {location.x, location.y, plant_height * 0.70}
				color: rgb(145, 160, 55);

			draw sphere(0.14)
				at: {location.x, location.y, plant_height + 0.08}
				color: rgb(225, 185, 55);
		}

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "ripening"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}

	aspect mesh3d {
		if !has_pest_damage {
			draw obj_file("../fbx/gama/Plants/RicePlant_Ripening.gama.obj", 90::{-1, 0, 0})
				size: 2.10
				at: location
				color: rgb(205, 175, 55);
		}
	}
}

species animal_template skills: [moving] {

	string stage_id;
	string stage_name;
	string animal_id;
	string animal_name;
	string species_id;
	string species_name;
	string scientific_name;
	string life_stage;
	string ecological_role;
	string prefab_name;
	string unity_resource_path;
	string asset_status;
	string spawn_point_id;
	string coordinate_frame;
	string spawn_surface;

	float species_density_per_100m2 <- 0.0;
	float life_stage_fraction <- 0.0;

	bool is_pest <- false;
	string movement_mode <- "ground";

	point movement_direction <- {1.0, 0.0, 0.0};
	point target_movement_direction <- {1.0, 0.0, 0.0};
	// Retained for VU3-created stationary eggs and older VR consumers.
	point movement_destination;
	bool movement_direction_initialized <- false;
	int direction_timer <- 0;
	float movement_speed <- 0.0001;
	float steering_rate <- 0.12;
	float movement_heading <- 0.0;
	bool has_movement_heading <- false;

	// Generic lifecycle state. VU2 does not act on these fields; child models
	// such as VU3 can add reproduction without replacing the base animal model.
	bool spawned_by_reproduction <- false;
	int eggs_laid <- 0;
	int next_egg_laying_cycle <- 0;
	agent host_rice;

	action setup_from_csv_rows(
		int type_row,
		int population_row,
		list<int> matching_spawn_rows
	) {

		int spawn_row <- one_of(matching_spawn_rows);

		stage_id <- string(stage_populations_data[0, population_row]);
		stage_name <- string(stage_populations_data[1, population_row]);
		animal_id <- string(animal_types_data[0, type_row]);
		animal_name <- string(animal_types_data[1, type_row]);
		species_id <- string(animal_types_data[2, type_row]);
		species_name <- string(animal_types_data[3, type_row]);
		scientific_name <- string(animal_types_data[4, type_row]);
		life_stage <- string(animal_types_data[5, type_row]);
		ecological_role <- string(animal_types_data[6, type_row]);
		movement_mode <- string(animal_types_data[8, type_row]);
		spawn_surface <- string(animal_types_data[9, type_row]);
		float speed_min <- float(animal_types_data[10, type_row]);
		float speed_max <- float(animal_types_data[11, type_row]);
		prefab_name <- string(animal_types_data[12, type_row]);
		unity_resource_path <- string(animal_types_data[13, type_row]);
		asset_status <- string(animal_types_data[14, type_row]);

		species_density_per_100m2 <- float(stage_populations_data[4, population_row]);
		life_stage_fraction <- float(stage_populations_data[5, population_row]);

		spawn_point_id <- string(spawn_points_data[2, spawn_row]);
		float local_x <- float(spawn_points_data[3, spawn_row]);
		float local_y <- float(spawn_points_data[4, spawn_row]);
		float local_z <- float(spawn_points_data[5, spawn_row]);
		coordinate_frame <- string(spawn_points_data[6, spawn_row]);

		is_pest <- ecological_role = "pest";
		float start_z <- get_start_height(movement_mode, local_z);

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
		movement_destination <- location;

		movement_speed <- get_scaled_movement_speed(movement_mode, speed_min, speed_max);
		if species_id = "duck" or species_id = "snake" or species_id = "fish" {
			steering_rate <- 0.05;
		}

		if species_id = "duck" {
			location <- constrain_duck_to_field_edge(location.x, location.y, location.z);
		}

		heading <- movement_heading;
		has_movement_heading <- true;

		if movement_mode != "stationary" and movement_speed > 0.0 {
			do choose_new_direction;
		}
	}

	action update_population_metadata(int population_row) {
		stage_id <- string(stage_populations_data[0, population_row]);
		stage_name <- string(stage_populations_data[1, population_row]);
		species_density_per_100m2
			<- float(stage_populations_data[4, population_row]);
		life_stage_fraction
			<- float(stage_populations_data[5, population_row]);
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

	point constrain_duck_to_field_edge(float proposed_x, float proposed_y, float z_value) {
		float edge_margin <- spacing * 0.5;
		float minimum_x <- field_min_x + edge_margin;
		float maximum_x <- field_max_x - edge_margin;
		float minimum_y <- field_min_y + edge_margin;
		float maximum_y <- field_max_y - edge_margin;
		float distance_left <- abs(proposed_x - field_min_x);
		float distance_right <- abs(proposed_x - field_max_x);
		float distance_bottom <- abs(proposed_y - field_min_y);
		float distance_top <- abs(proposed_y - field_max_y);
		float nearest_distance <- min([distance_left, distance_right, distance_bottom, distance_top]);

		if nearest_distance = distance_left {
			return {
				minimum_x,
				max([minimum_y, min([maximum_y, proposed_y])]),
				z_value
			};
		}

		if nearest_distance = distance_right {
			return {
				maximum_x,
				max([minimum_y, min([maximum_y, proposed_y])]),
				z_value
			};
		}

		if nearest_distance = distance_bottom {
			return {
				max([minimum_x, min([maximum_x, proposed_x])]),
				minimum_y,
				z_value
			};
		}

		return {
			max([minimum_x, min([maximum_x, proposed_x])]),
			maximum_y,
			z_value
		};
	}

	float get_start_height(string move_mode, float csv_z) {

		if move_mode = "fly" {
			return max([1.5, min([4.0, abs(csv_z) + 1.0])]);
		}

		if move_mode = "plant" {
			return max([0.25, min([1.8, abs(csv_z)])]);
		}

		if move_mode = "water" {
			if species_id = "duck" {
				return water_level + 0.02;
			}
			return max([0.0, min([water_level, abs(csv_z)])]);
		}

		if move_mode = "stationary" {
			return max([0.15, min([1.5, abs(csv_z)])]);
		}

		return max([0.0, min([0.20, abs(csv_z)])]);
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

	float get_scaled_movement_speed(
		string move_mode,
		float speed_min,
		float speed_max
	) {
		if move_mode = "stationary" or speed_max <= 0.0 {
			return 0.0;
		}

		float base_speed <- speed_min = speed_max
			? speed_min
			: rnd(speed_min, speed_max);

		float scaled_speed <- base_speed * animal_movement_speed_scale;

		if species_id = "fish" {
			scaled_speed <- scaled_speed * 0.25;
		} else if species_id = "duck" {
			scaled_speed <- scaled_speed * 0.40;
		} else if species_id = "snake" {
			scaled_speed <- scaled_speed * 0.20;
		}

		if move_mode = "fly" {
			return min([scaled_speed, max_flying_speed_m_per_cycle]);
		}

		if move_mode = "plant" {
			return min([scaled_speed, max_plant_speed_m_per_cycle]);
		}

		if move_mode = "water" {
			if species_id = "fish" {
				return min([scaled_speed, 0.003]);
			}
			if species_id = "duck" {
				return min([scaled_speed, 0.004]);
			}
			return min([scaled_speed, max_water_speed_m_per_cycle]);
		}

		if species_id = "snake" {
			return min([scaled_speed, 0.0015]);
		}

		return min([scaled_speed, max_ground_speed_m_per_cycle]);
	}

	action choose_new_direction {

		float direction_x <- rnd(-1.0, 1.0);
		float direction_y <- rnd(-1.0, 1.0);
		float direction_z <- 0.0;

		if movement_mode = "fly" {
			direction_z <- rnd(-0.35, 0.35);
		} else if movement_mode = "plant" {
			direction_z <- rnd(-0.15, 0.15);
		}

		if abs(direction_x) + abs(direction_y) < 0.01 {
			direction_x <- 1.0;
		}

		float direction_length <- sqrt(
			direction_x * direction_x
			+ direction_y * direction_y
			+ direction_z * direction_z
		);

		target_movement_direction <- {
			direction_x / direction_length,
			direction_y / direction_length,
			direction_z / direction_length
		};

		if !movement_direction_initialized {
			movement_direction <- target_movement_direction;
			movement_direction_initialized <- true;
		}

		if species_id = "snake" {
			direction_timer <- rnd(180, 360);
		} else if species_id = "fish" {
			direction_timer <- rnd(120, 240);
		} else if species_id = "duck" {
			direction_timer <- rnd(160, 300);
		} else {
			direction_timer <- rnd(60, 140);
		}
		do update_heading_from_direction;
	}

	action steer_towards_target_direction {

		float direction_x <- movement_direction.x * (1.0 - steering_rate)
			+ target_movement_direction.x * steering_rate;
		float direction_y <- movement_direction.y * (1.0 - steering_rate)
			+ target_movement_direction.y * steering_rate;
		float direction_z <- movement_direction.z * (1.0 - steering_rate)
			+ target_movement_direction.z * steering_rate;

		float direction_length <- sqrt(
			direction_x * direction_x
			+ direction_y * direction_y
			+ direction_z * direction_z
		);

		if direction_length > 0.001 {
			movement_direction <- {
				direction_x / direction_length,
				direction_y / direction_length,
				direction_z / direction_length
			};
		}

		do update_heading_from_direction;
	}

	action update_heading_from_direction {

		if abs(movement_direction.x) > 0.001
			or abs(movement_direction.y) > 0.001 {

			float new_heading <- atan2(
				movement_direction.y,
				movement_direction.x
			);

			if new_heading < 0.0 {
				new_heading <- new_heading + 360.0;
			}

			float heading_delta <- abs(new_heading - movement_heading);

			if heading_delta > 180.0 {
				heading_delta <- 360.0 - heading_delta;
			}

			if !has_movement_heading or heading_delta > 0.1 {
				movement_heading <- new_heading;
				heading <- movement_heading;
				has_movement_heading <- true;
			}
		}
	}

	bool is_near_active_rice_crop {
		if rice_stage = "vegetative" {
			return !empty(vegetative_rice_plant where (
				(each.location distance_to location) <= default_pest_impact_radius_m
			));
		}

		if rice_stage = "reproductive" {
			return !empty(reproductive_rice_plant where (
				(each.location distance_to location) <= default_pest_impact_radius_m
			));
		}

		return !empty(ripening_rice_plant where (
			(each.location distance_to location) <= default_pest_impact_radius_m
		));
	}

	reflex move_independently when: animal_movement_speed_scale > 0.0 {

		bool pest_is_resting_on_rice <- is_pest and is_near_active_rice_crop();

		if pest_is_resting_on_rice {
			movement_destination <- location;
		} else if movement_mode != "stationary" and movement_speed > 0.0 {

			direction_timer <- direction_timer - 1;

			if direction_timer <= 0 {
				do choose_new_direction;
			}

			do steer_towards_target_direction;

			float direction_x <- movement_direction.x;
			float direction_y <- movement_direction.y;
			float direction_z <- movement_direction.z;
			float target_direction_x <- target_movement_direction.x;
			float target_direction_y <- target_movement_direction.y;
			float target_direction_z <- target_movement_direction.z;

			float next_x <- location.x + direction_x * movement_speed;
			float next_y <- location.y + direction_y * movement_speed;
			float next_z <- location.z + direction_z * movement_speed;

			if next_x < field_min_x or next_x > field_max_x {
				direction_x <- -direction_x;
				target_direction_x <- -target_direction_x;
				next_x <- location.x + direction_x * movement_speed;
			}

			if next_y < field_min_y or next_y > field_max_y {
				direction_y <- -direction_y;
				target_direction_y <- -target_direction_y;
				next_y <- location.y + direction_y * movement_speed;
			}

			if movement_mode = "fly" {
				if next_z < 1.2 or next_z > 4.0 {
					direction_z <- -direction_z;
					target_direction_z <- -target_direction_z;
					next_z <- location.z + direction_z * movement_speed;
				}
				next_z <- max([1.2, min([4.0, next_z])]);
			} else if movement_mode = "plant" {
				if next_z < 0.25 or next_z > 1.70 {
					direction_z <- -direction_z;
					target_direction_z <- -target_direction_z;
					next_z <- location.z + direction_z * movement_speed;
				}
				next_z <- max([0.25, min([1.70, next_z])]);
			} else if movement_mode = "water" {
				if species_id = "duck" {
					next_z <- water_level + 0.02;
				} else {
					next_z <- max([0.0, min([water_level, location.z])]);
				}
			} else {
				next_z <- location.z;
			}

			if species_id = "duck" {
				point edge_location <- constrain_duck_to_field_edge(next_x, next_y, next_z);
				next_x <- edge_location.x;
				next_y <- edge_location.y;
				next_z <- edge_location.z;
			}

			movement_direction <- {direction_x, direction_y, direction_z};
			target_movement_direction <- {
				target_direction_x,
				target_direction_y,
				target_direction_z
			};
			location <- {
				max([field_min_x, min([field_max_x, next_x])]),
				max([field_min_y, min([field_max_y, next_y])]),
				next_z
			};

			do update_heading_from_direction;
		} else {
			movement_speed <- 0.0;
			movement_destination <- location;
		}
	}

	rgb marker_color_for_species {
		if species_id = "brown_planthopper" { return rgb(130, 75, 30); }
		if species_id = "leaf_folder" { return rgb(225, 70, 45); }
		if species_id = "lynx_spider" { return rgb(125, 55, 175); }
		if species_id = "trichogramma" { return rgb(245, 185, 25); }
		if species_id = "dragonfly" { return rgb(20, 175, 210); }
		if species_id = "worm" { return rgb(225, 105, 155); }
		if species_id = "frog" { return rgb(45, 165, 70); }
		if species_id = "yellow_stem_borer" { return rgb(235, 145, 20); }
		if species_id = "golden_apple_snail" { return rgb(155, 135, 35); }
		if species_id = "wasp" { return rgb(65, 55, 35); }
		if species_id = "weaver_ant" { return rgb(155, 35, 50); }
		if species_id = "butterfly" { return rgb(210, 60, 190); }
		if species_id = "bee" { return rgb(250, 115, 20); }
		if species_id = "bird" { return rgb(65, 120, 220); }
		if species_id = "rat" { return rgb(115, 115, 125); }
		if species_id = "ladybug" { return rgb(220, 30, 35); }
		if species_id = "duck" { return rgb(30, 145, 135); }
		if species_id = "snake" { return rgb(35, 105, 45); }
		if species_id = "cricket" { return rgb(105, 70, 45); }
		if species_id = "fish" { return rgb(30, 85, 190); }
		return #cyan;
	}

	string marker_shape_for_species {
		if species_id in ["brown_planthopper", "dragonfly", "bird"] {
			return "triangle";
		}
		if species_id in [
			"lynx_spider",
			"yellow_stem_borer",
			"rat",
			"cricket"
		] {
			return "square";
		}
		if species_id in [
			"leaf_folder",
			"wasp",
			"butterfly",
			"duck",
			"fish"
		] {
			return "diamond";
		}
		if species_id in ["trichogramma", "worm", "weaver_ant", "snake"] {
			return "bar";
		}
		return "sphere";
	}

	string mesh_asset_path {
		if animal_id = "brown_planthopper_eggs" { return "../fbx/gama/Animals/BrownPlanthopper_Eggs.gama.obj"; }
		if animal_id = "brown_planthopper_nymph" { return "../fbx/gama/Animals/BrownPlanthopper_Nymph.gama.obj"; }
		if animal_id = "brown_planthopper_adult" { return "../fbx/gama/Animals/BrownPlanthopper_Adult.gama.obj"; }
		if animal_id = "leaf_folder_eggs" { return "../fbx/gama/Animals/LeafFolder_Eggs.gama.obj"; }
		if animal_id = "leaf_folder_larva" { return "../fbx/gama/Animals/LeafFolder_Larva.gama.obj"; }
		if animal_id = "leaf_folder_adult" { return "../fbx/gama/Animals/LeafFolder_Adult.gama.obj"; }
		if animal_id = "yellow_stem_borer_eggs" { return "../fbx/gama/Animals/YellowStemBorer_Eggs.gama.obj"; }
		if animal_id = "golden_apple_snail_eggs" { return "../fbx/gama/Animals/GoldenAppleSnail_Eggs.gama.obj"; }
		if animal_id = "golden_apple_snail_adult" { return "../fbx/gama/Animals/GoldenAppleSnail.gama.obj"; }
		if species_id = "rat" { return "../fbx/gama/Animals/Rat.gama.obj"; }
		if species_id = "bird" { return "../fbx/gama/Animals/Bird.gama.obj"; }
		if species_id = "ladybug" { return "../fbx/gama/Animals/Ladybug.gama.obj"; }
		if species_id = "dragonfly" { return "../fbx/gama/Animals/Dragonfly.gama.obj"; }
		if species_id = "duck" { return "../fbx/gama/Animals/Duck.gama.obj"; }
		if species_id = "fish" { return "../fbx/gama/Animals/Fish.gama.obj"; }
		if species_id = "frog" { return "../fbx/gama/Animals/Frog.gama.obj"; }
		if species_id = "weaver_ant" { return "../fbx/gama/Animals/WeaverAnt.gama.obj"; }
		if species_id = "lynx_spider" { return "../fbx/gama/Animals/Spider.gama.obj"; }
		if species_id = "wasp" { return "../fbx/gama/Animals/Wasp.gama.obj"; }
		if species_id = "trichogramma" { return "../fbx/gama/Animals/Trichogramma.gama.obj"; }
		if species_id = "worm" { return "../fbx/gama/Animals/Worm.gama.obj"; }
		if species_id = "bee" { return "../fbx/gama/Animals/Bee.gama.obj"; }
		if species_id = "butterfly" { return "../fbx/gama/Animals/Butterfly.gama.obj"; }
		if species_id = "cricket" { return "../fbx/gama/Animals/Cricket.gama.obj"; }
		if species_id = "snake" { return "../fbx/gama/Animals/Snake.gama.obj"; }
		return "";
	}

	float mesh_size {
		if movement_mode = "fly" { return 0.90; }
		if movement_mode = "water" { return 1.10; }
		if movement_mode = "stationary" { return 0.55; }
		if species_id in ["golden_apple_snail", "rat", "duck", "snake"] { return 1.20; }
		return 0.80;
	}

	aspect mesh3d {
		string mesh_path <- mesh_asset_path();

		if mesh_path != "" {
			draw obj_file(mesh_path, 90::{-1, 0, 0})
				size: mesh_size()
				at: location
				rotate: heading - 90.0
				color: marker_color_for_species();
		} else {
			draw sphere(0.18) at: location color: marker_color_for_species();
		}
	}

	aspect default {

		rgb marker_color <- marker_color_for_species();
		string marker_shape <- marker_shape_for_species();
		float body_size <- 0.18;

		if movement_mode = "fly" {
			body_size <- 0.22;
		} else if movement_mode = "water" {
			body_size <- 0.28;
		} else if movement_mode = "stationary" {
			body_size <- 0.12;
		}

		if animal_markers_are_triangles or marker_shape = "triangle" {
			draw triangle(body_size * 2.0)
				at: location
				rotate: heading + 90.0
				color: marker_color;
		} else if marker_shape = "square" {
			draw rectangle(body_size * 2.0, body_size * 2.0)
				at: location
				color: marker_color;
		} else if marker_shape = "diamond" {
			draw rectangle(body_size * 2.0, body_size * 2.0)
				at: location
				rotate: 45.0
				color: marker_color;
		} else if marker_shape = "bar" {
			draw rectangle(body_size * 2.8, body_size)
				at: location
				rotate: heading
				color: marker_color;
		} else {
			draw sphere(body_size)
				at: location
				color: marker_color;
		}

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

species pest_impact {

	string interaction_key;
	string source_pest_id;
	string source_pest_name;
	string source_pest_life_stage;
	string affected_rice_id;
	string affected_rice_stage;
	string damage_prefab_name;
	int contributing_pest_count <- 0;
	float combined_damage_score <- 0.0;
	float damaged_plant_height <- 1.25;
	float damaged_canopy_size <- 0.42;
	rgb damage_color <- rgb(255, 55, 35);

	rgb damage_color_for_prefab(string damage_prefab) {
		if damage_prefab = "BPH_Vegetative_Severe.prefab" { return rgb(128, 70, 28); }
		if damage_prefab = "BPH_Reproductive_Severe.prefab" { return rgb(145, 80, 32); }
		if damage_prefab = "BPH_Ripening_Severe.prefab" { return rgb(165, 90, 36); }
		if damage_prefab = "GAS_Vegetative_Severe.prefab" { return rgb(125, 132, 34); }
		if damage_prefab = "GAS_Reproductive_Severe.prefab" { return rgb(155, 145, 38); }
		if damage_prefab = "YSB_Vegetative_Severe.prefab" { return rgb(230, 145, 20); }
		if damage_prefab = "YSB_Reproductive_Severe.prefab" { return rgb(245, 170, 35); }
		if damage_prefab = "LF_Vegetative_Severe.prefab" { return rgb(220, 70, 45); }
		if damage_prefab = "LF_Reproductive_Severe.prefab" { return rgb(235, 90, 55); }
		if damage_prefab = "LF_Ripening_Severe.prefab" { return rgb(245, 110, 70); }
		if damage_prefab = "R_Ripening.prefab" { return rgb(115, 115, 125); }
		if damage_prefab = "B_Ripening.prefab" { return rgb(65, 120, 220); }

		return rgb(255, 55, 35);
	}

	action setup_pest_impact(
		string source_id,
		string source_name,
		string source_life_stage,
		string rice_id,
		string damage_prefab,
		point rice_location,
		int pest_count
	) {
		interaction_key <- rice_id + "|" + rice_stage + "|" + damage_prefab;
		source_pest_id <- source_id;
		source_pest_name <- source_name;
		source_pest_life_stage <- source_life_stage;
		affected_rice_id <- rice_id;
		affected_rice_stage <- rice_stage;
		damage_prefab_name <- damage_prefab;
		contributing_pest_count <- pest_count;
		combined_damage_score <- float(pest_count);
		damage_color <- damage_color_for_prefab(damage_prefab);
		location <- rice_location;

		if rice_stage = "vegetative" {
			damaged_plant_height <- 1.00;
			damaged_canopy_size <- 0.38;
		} else if rice_stage = "reproductive" {
			damaged_plant_height <- 1.45;
			damaged_canopy_size <- 0.48;
		} else {
			damaged_plant_height <- 1.70;
			damaged_canopy_size <- 0.52;
		}
	}

	string mesh_asset_path {
		if damage_prefab_name = "BPH_Vegetative_Severe.prefab" { return "../fbx/gama/Damage/Damage_Vegetative_Sap_sucking_damage.gama.obj"; }
		if damage_prefab_name = "BPH_Reproductive_Severe.prefab" { return "../fbx/gama/Damage/Damage_Reproductive_Sap_sucking_damage.gama.obj"; }
		if damage_prefab_name = "BPH_Ripening_Severe.prefab" { return "../fbx/gama/Damage/Damage_Ripening_Sap_sucking_damage.gama.obj"; }
		if damage_prefab_name = "GAS_Vegetative_Severe.prefab" { return "../fbx/gama/Damage/Damage_Vegetative_Seedling_and_leaf_feeding_damage.gama.obj"; }
		if damage_prefab_name = "GAS_Reproductive_Severe.prefab" { return "../fbx/gama/Damage/Damage_Reproductive_Leaf_and_stem_feeding_damage.gama.obj"; }
		if damage_prefab_name = "YSB_Vegetative_Severe.prefab" { return "../fbx/gama/Damage/Damage_Vegetative_Deadhead_damage.gama.obj"; }
		if damage_prefab_name = "YSB_Reproductive_Severe.prefab" { return "../fbx/gama/Damage/Damage_Reproductive_Whitehead_damage.gama.obj"; }
		if damage_prefab_name = "LF_Vegetative_Severe.prefab" { return "../fbx/gama/Damage/Damage_Vegetative_Leaf_folding_and_feeding_damage.gama.obj"; }
		if damage_prefab_name = "LF_Reproductive_Severe.prefab" { return "../fbx/gama/Damage/Damage_Reproductive_Leaf_folding_and_feeding_damage.gama.obj"; }
		if damage_prefab_name = "LF_Ripening_Severe.prefab" { return "../fbx/gama/Damage/Damage_Ripening_Leaf_folding_and_feeding_damage.gama.obj"; }
		if damage_prefab_name = "R_Ripening.prefab" { return "../fbx/gama/Damage/Damage_Ripening_Panicle_and_grain_feeding_damage.gama.obj"; }
		if damage_prefab_name = "B_Ripening.prefab" { return "../fbx/gama/Damage/Damage_Ripening_Grain_feeding_damage.gama.obj"; }
		return "";
	}

	aspect mesh3d {
		string mesh_path <- mesh_asset_path();

		if mesh_path != "" {
			draw obj_file(mesh_path, 90::{-1, 0, 0})
				size: damaged_plant_height + 0.50
				at: location
				color: damage_color;
		} else {
			draw sphere(0.22)
				at: {location.x, location.y, location.z + damaged_plant_height}
				color: damage_color;
		}
	}

	aspect default {
		draw cylinder(0.07, damaged_plant_height)
			at: {
				location.x,
				location.y,
				location.z + damaged_plant_height / 2.0
			}
			color: rgb(95, 80, 45);

		draw sphere(damaged_canopy_size)
			at: {location.x, location.y, location.z + damaged_plant_height * 0.70}
			color: damage_color;

		draw sphere(0.10 + min([0.18, combined_damage_score * 0.015]))
			at: {location.x, location.y, location.z + damaged_plant_height + 0.05}
			color: rgb(95, 55, 35);

		if show_pest_damage_labels {
			draw source_pest_name + " damage x" + string(contributing_pest_count)
				at: {
					location.x,
					location.y,
					location.z + damaged_plant_height + 0.45
				}
				color: #red
				size: 0.45;
		}
	}
}

species bph_vegetative_damage parent: pest_impact {
}

species bph_reproductive_damage parent: pest_impact {
}

species bph_ripening_damage parent: pest_impact {
}

species gas_vegetative_damage parent: pest_impact {
}

species gas_reproductive_damage parent: pest_impact {
}

species ysb_vegetative_damage parent: pest_impact {
}

species ysb_reproductive_damage parent: pest_impact {
}

species lf_vegetative_damage parent: pest_impact {
}

species lf_reproductive_damage parent: pest_impact {
}

species lf_ripening_damage parent: pest_impact {
}

species rat_ripening_damage parent: pest_impact {
}

species bird_ripening_damage parent: pest_impact {
}

experiment vu2_main_3D_complete type: gui {

	parameter "Rice growth stage"
		var: rice_stage
		among: ["vegetative", "reproductive", "ripening"];

	parameter "Automatically progress rice stage"
		var: auto_progress_rice_stage;

	parameter "Stage duration in cycles"
		var: stage_duration_cycles
		min: 30
		max: 2000
		step: 1000;

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

	parameter "Animal movement speed scale"
		var: animal_movement_speed_scale
		min: 0.0
		max: 1.0
		step: 0.05;

	parameter "Enable pest impacts"
		var: enable_pest_impacts;

	parameter "Show pest damage labels"
		var: show_pest_damage_labels;

	output synchronized: true {

		display "VU2 Main 3D"
			type: 3d
			background: rgb(210, 230, 240) {

			camera 'default'
				location: {field_center_x, field_center_y + 58.0, 45.0}
				target: {field_center_x, field_center_y, 0.0};

			light #ambient intensity: 180;

			graphics "3D reference" {
				draw cube(0.8)
					at: {field_min_x, field_min_y, 0.4}
					color: #red;
				draw cube(0.8)
					at: {field_max_x, field_min_y, 0.4}
					color: #green;
				draw cube(0.8)
					at: {field_min_x, field_max_y, 0.4}
					color: #blue;
				draw cylinder(0.35, 5.0)
					at: {field_center_x, field_center_y, 2.5}
					color: #yellow;
			}

			species field_ground aspect: default;
			species water aspect: default;
			species vegetative_rice_plant aspect: mesh3d;
			species reproductive_rice_plant aspect: mesh3d;
			species ripening_rice_plant aspect: mesh3d;

			species bph_vegetative_damage aspect: mesh3d;
			species bph_reproductive_damage aspect: mesh3d;
			species bph_ripening_damage aspect: mesh3d;
			species gas_vegetative_damage aspect: mesh3d;
			species gas_reproductive_damage aspect: mesh3d;
			species ysb_vegetative_damage aspect: mesh3d;
			species ysb_reproductive_damage aspect: mesh3d;
			species lf_vegetative_damage aspect: mesh3d;
			species lf_reproductive_damage aspect: mesh3d;
			species lf_ripening_damage aspect: mesh3d;
			species rat_ripening_damage aspect: mesh3d;
			species bird_ripening_damage aspect: mesh3d;

			species brown_planthopper aspect: mesh3d;
			species leaf_folder aspect: mesh3d;
			species lynx_spider aspect: mesh3d;
			species trichogramma aspect: mesh3d;
			species dragonfly aspect: mesh3d;
			species worm aspect: mesh3d;
			species frog aspect: mesh3d;
			species yellow_stem_borer aspect: mesh3d;
			species golden_apple_snail aspect: mesh3d;
			species wasp aspect: mesh3d;
			species weaver_ant aspect: mesh3d;
			species butterfly aspect: mesh3d;
			species bee aspect: mesh3d;
			species bird aspect: mesh3d;
			species rat aspect: mesh3d;
			species ladybug aspect: mesh3d;
			species duck aspect: mesh3d;
			species snake aspect: mesh3d;
			species cricket aspect: mesh3d;
			species fish aspect: mesh3d;
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

		monitor "Pest impacts"
			value: pest_impact_count();
	}
}
