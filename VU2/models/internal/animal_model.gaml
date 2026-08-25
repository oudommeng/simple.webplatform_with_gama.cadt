model animal_model

// Animal creation, movement, and rendering use the shared CSV and field data.
import "vu2_config.gaml"
import "rice_model.gaml"

global {

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
		ask native_snail { do die; }
		ask river_snail { do die; }
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
		if gama_species_value = "native_snail" { return length(native_snail where (each.animal_id = row_animal_id)); }
		if gama_species_value = "river_snail" { return length(river_snail where (each.animal_id = row_animal_id)); }
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
		else if gama_species_value = "native_snail" { ask native_snail where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
		else if gama_species_value = "river_snail" { ask river_snail where (each.animal_id = row_animal_id) { do update_population_metadata(population_row); } }
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
							} else if gama_species_value = "native_snail" {
								create native_snail number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
							} else if gama_species_value = "river_snail" {
								create river_snail number: additional_count { do setup_from_csv_rows(type_row, population_row, matching_spawn_rows); }
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
		if species_id = "native_snail" { return rgb(85, 145, 95); }
		if species_id = "river_snail" { return rgb(60, 125, 165); }
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
		if animal_id = "brown_planthopper_eggs" { return "../fbx/Animals/BrownPlanthopper_Eggs.gama.obj"; }
		if animal_id = "brown_planthopper_nymph" { return "../fbx/Animals/BrownPlanthopper_Nymph.gama.obj"; }
		if animal_id = "brown_planthopper_adult" { return "../fbx/Animals/BrownPlanthopper_Adult.gama.obj"; }
		if animal_id = "leaf_folder_eggs" { return "../fbx/Animals/LeafFolder_Eggs.gama.obj"; }
		if animal_id = "leaf_folder_larva" { return "../fbx/Animals/LeafFolder_Larva.gama.obj"; }
		if animal_id = "leaf_folder_adult" { return "../fbx/Animals/LeafFolder_Adult.gama.obj"; }
		if animal_id = "yellow_stem_borer_eggs" { return "../fbx/Animals/YellowStemBorer_Eggs.gama.obj"; }
		if animal_id = "golden_apple_snail_eggs" { return "../fbx/Animals/GoldenAppleSnail_Eggs.gama.obj"; }
		if animal_id = "golden_apple_snail_adult" { return "../fbx/Animals/GoldenAppleSnail.gama.obj"; }
		if animal_id = "native_snail_adult" { return "../fbx/Animals/NativeSnail.gama.obj"; }
		if animal_id = "river_snail_adult" { return "../fbx/Animals/RiverSnail.gama.obj"; }
		if species_id = "rat" { return "../fbx/Animals/Rat.gama.obj"; }
		if species_id = "bird" { return "../fbx/Animals/Bird.gama.obj"; }
		if species_id = "ladybug" { return "../fbx/Animals/Ladybug.gama.obj"; }
		if species_id = "dragonfly" { return "../fbx/Animals/Dragonfly.gama.obj"; }
		if species_id = "duck" { return "../fbx/Animals/Duck.gama.obj"; }
		if species_id = "fish" { return "../fbx/Animals/Fish.gama.obj"; }
		if species_id = "frog" { return "../fbx/Animals/Frog.gama.obj"; }
		if species_id = "weaver_ant" { return "../fbx/Animals/WeaverAnt.gama.obj"; }
		if species_id = "lynx_spider" { return "../fbx/Animals/Spider.gama.obj"; }
		if species_id = "wasp" { return "../fbx/Animals/Wasp.gama.obj"; }
		if species_id = "trichogramma" { return "../fbx/Animals/Trichogramma.gama.obj"; }
		if species_id = "worm" { return "../fbx/Animals/Worm.gama.obj"; }
		if species_id = "bee" { return "../fbx/Animals/Bee.gama.obj"; }
		if species_id = "butterfly" { return "../fbx/Animals/Butterfly.gama.obj"; }
		if species_id = "cricket" { return "../fbx/Animals/Cricket.gama.obj"; }
		if species_id = "snake" { return "../fbx/Animals/Snake.gama.obj"; }
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

species native_snail parent: animal_template {
}

species river_snail parent: animal_template {
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
