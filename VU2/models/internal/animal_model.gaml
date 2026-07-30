model animal_model

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

	action clear_animals_for_stage_change {
		ask brown_planthopper { do die; }
		ask leaf_folder { do die; }
		ask lynx_spider { do die; }
		ask trichogramma { do die; }
		ask dragonfly { do die; }
		ask worm { do die; }
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

	action sync_frogs_for_stage(list<int> matching_rows, int desired_count) {

		int current_count <- length(frog);

		if current_count < desired_count {
			create frog number: desired_count - current_count {
				do setup_from_csv_rows(matching_rows);
			}
		} else if current_count > desired_count {
			ask ((current_count - desired_count) among frog) {
				do die;
			}
		}

		if !empty(matching_rows) {
			int stage_row <- first(matching_rows);
			ask frog {
				stage_id <- string(animal_data[0, stage_row]);
				stage_name <- string(animal_data[1, stage_row]);
				density_per_100m2 <- float(animal_data[8, stage_row]);
			}
		}
	}

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
						do sync_frogs_for_stage(matching_rows, desired_count);
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

	point movement_direction <- {1.0, 0.0, 0.0};
	point target_movement_direction <- {1.0, 0.0, 0.0};
	bool movement_direction_initialized <- false;
	int direction_timer <- 0;
	float movement_speed <- 0.0001;
	float steering_rate <- 0.12;
	float movement_heading <- 0.0;
	bool has_movement_heading <- false;

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
		heading <- movement_heading;
		has_movement_heading <- true;

		if movement_mode != "stationary" {
			do choose_new_direction;
		}
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

		direction_timer <- rnd(60, 140);
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

	reflex move_independently {

		// Egg records and other stationary records do not move.
		if movement_mode != "stationary" {

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
				next_z <- 0.10;
			} else {
				next_z <- location.z;
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
