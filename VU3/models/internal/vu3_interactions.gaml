model vu3_interactions

global {

	// One ordered reflex guarantees the required behavior:
	// beneficial control happens first, then only surviving pests add impact.
	reflex vu3_ecosystem_step when: vu3_interactions_enabled {

		ask rice_impact {
			do die;
		}

		vu3_pests_controlled_this_cycle <- 0;
		vu3_bph_eggs_laid_this_cycle <- 0;

		if vu3_bph_egg_laying_enabled {
			list<brown_planthopper> bph_adults
				<- brown_planthopper where (each.life_stage = "adult");

			loop adult_agent over: bph_adults {
				do vu3_try_bph_egg_laying(adult_agent);
			}
		}

		list<animal_template> all_animals
			<- agents of_generic_species animal_template;

		list<animal_template> beneficials <- [];

		loop animal_agent over: all_animals {
			if vu3_is_active_beneficial(animal_agent) {
				beneficials << animal_agent;
			}
		}

		loop beneficial_agent over: beneficials {
			do vu3_try_beneficial_control(beneficial_agent);
		}

		// Refresh the list because controlled pests have died.
		all_animals <- agents of_generic_species animal_template;
		list<animal_template> surviving_pests <- [];

		loop animal_agent over: all_animals {
			// Eggs remain valid targets for parasitoids, but eggs themselves
			// do not suck sap, fold leaves, bore stems, or eat grain.
			if vu3_is_active_pest(animal_agent)
				and animal_agent.life_stage != "eggs" {

				surviving_pests << animal_agent;
			}
		}

		loop pest_agent over: surviving_pests {
			do vu3_apply_pest_impact(pest_agent);
		}
	}

	action vu3_try_bph_egg_laying(brown_planthopper adult_agent) {

		if adult_agent.eggs_laid < vu3_bph_max_eggs_per_adult
			and cycle >= adult_agent.next_egg_laying_cycle {

			list<agent> rice_plants <- list(vegetative_rice_plant)
				+ list(reproductive_rice_plant)
				+ list(ripening_rice_plant);

			agent nearest_rice <- nil;
			float nearest_distance <- 1000000.0;

			loop rice_agent over: rice_plants {
				float rice_distance
					<- vu3_planar_distance(adult_agent, rice_agent);

				if rice_distance < nearest_distance {
					nearest_distance <- rice_distance;
					nearest_rice <- rice_agent;
				}
			}

			if nearest_rice != nil
				and nearest_distance <= vu3_bph_egg_laying_radius_m {

				int eggs_on_rice <- 0;

				loop egg_agent over: brown_planthopper {
					if egg_agent.life_stage = "eggs"
						and egg_agent.spawned_by_reproduction
						and egg_agent.host_rice = nearest_rice {

						eggs_on_rice <- eggs_on_rice + 1;
					}
				}

				if eggs_on_rice < vu3_bph_max_eggs_per_rice
					and flip(vu3_bph_egg_laying_probability) {

					do vu3_create_bph_egg(adult_agent, nearest_rice);
				}
			}
		}
	}

	action vu3_create_bph_egg(
		brown_planthopper adult_agent,
		agent rice_agent
	) {

		float egg_height <- 0.70;

		if rice_stage = "reproductive" {
			egg_height <- 1.05;
		} else if rice_stage = "ripening" {
			egg_height <- 1.25;
		}

		point egg_location <- {
			rice_agent.location.x,
			rice_agent.location.y,
			egg_height
		};

		string current_stage_name <- "Vegetative Stage";

		if rice_stage = "reproductive" {
			current_stage_name <- "Reproductive Stage";
		} else if rice_stage = "ripening" {
			current_stage_name <- "Ripening Stage";
		}

		string generated_spawn_id
			<- "laid_" + string(int(adult_agent)) + "_" + string(cycle);

		create brown_planthopper number: 1 {
			stage_id <- rice_stage;
			stage_name <- current_stage_name;
			animal_id <- "brown_planthopper_eggs";
			animal_name <- "Brown Planthopper - Eggs";
			species_id <- "brown_planthopper";
			species_name <- "Brown Planthopper";
			scientific_name <- "Nilaparvata lugens";
			life_stage <- "eggs";
			ecological_role <- "pest";
			prefab_name <- "SM_BPH_Eggs";
			unity_resource_path
				<- "Prefabs/Visual Prefabs/Prefabs/Animals/SM_BPH_Eggs";
			asset_status <- "configured";
			spawn_point_id <- generated_spawn_id;
			coordinate_frame <- "gama_field_local_m";
			spawn_surface <- "leaf";
			is_pest <- true;
			movement_mode <- "stationary";
			movement_speed <- 0.0;
			location <- egg_location;
			movement_destination <- egg_location;
			spawned_by_reproduction <- true;
			host_rice <- rice_agent;
		}

		ask adult_agent {
			eggs_laid <- eggs_laid + 1;
			next_egg_laying_cycle
				<- int(cycle) + vu3_bph_egg_laying_cooldown_cycles;
		}

		vu3_bph_eggs_laid_this_cycle
			<- vu3_bph_eggs_laid_this_cycle + 1;
		vu3_total_bph_eggs_laid <- vu3_total_bph_eggs_laid + 1;
	}

	action vu3_try_beneficial_control(animal_template beneficial_agent) {

		list<animal_template> all_animals
			<- agents of_generic_species animal_template;

		list<animal_template> candidates <- [];

		loop candidate over: all_animals {
			if vu3_is_active_pest(candidate)
				and vu3_planar_distance(candidate, beneficial_agent)
					<= vu3_beneficial_control_radius_m
				and vu3_can_control(beneficial_agent, candidate) {

				candidates << candidate;
			}
		}

		if !empty(candidates) and flip(vu3_beneficial_success_probability) {
			animal_template controlled_pest <- nil;
			float closest_distance <- 1000000.0;

			loop candidate over: candidates {
				float candidate_distance
					<- vu3_planar_distance(candidate, beneficial_agent);

				if candidate_distance < closest_distance {
					closest_distance <- candidate_distance;
					controlled_pest <- candidate;
				}
			}

			if controlled_pest != nil {
				ask controlled_pest {
					do die;
				}

				vu3_pests_controlled_this_cycle
					<- vu3_pests_controlled_this_cycle + 1;
				vu3_total_pests_controlled <- vu3_total_pests_controlled + 1;
			}
		}
	}

	float vu3_planar_distance(agent first_agent, agent second_agent) {
		float delta_x <- first_agent.location.x - second_agent.location.x;
		float delta_y <- first_agent.location.y - second_agent.location.y;
		return sqrt(delta_x * delta_x + delta_y * delta_y);
	}

	bool vu3_is_active_pest(animal_template animal_agent) {

		// The supplied vegetative specification contains exactly three pests.
		if rice_stage = "vegetative" {
			return animal_agent.species_id in [
				"brown_planthopper",
				"leaf_folder",
				"golden_apple_snail"
			];
		}

		// The supplied reproductive specification contains exactly three pests.
		if rice_stage = "reproductive" {
			return animal_agent.species_id in [
				"brown_planthopper",
				"leaf_folder",
				"yellow_stem_borer"
			];
		}

		// The supplied ripening specification contains exactly three pests.
		if rice_stage = "ripening" {
			return animal_agent.species_id in [
				"brown_planthopper",
				"rat",
				"bird"
			];
		}

		return false;
	}

	bool vu3_is_active_beneficial(animal_template animal_agent) {

		// Rat is intentionally a snail controller only in VU3 vegetative logic.
		if rice_stage = "vegetative" {
			return animal_agent.species_id in [
				"trichogramma",
				"wasp",
				"lynx_spider",
				"frog",
				"dragonfly",
				"duck",
				"rat"
			];
		}

		// Only the six controllers in the supplied reproductive table are active.
		if rice_stage = "reproductive" {
			return animal_agent.species_id in [
				"trichogramma",
				"wasp",
				"lynx_spider",
				"frog",
				"dragonfly",
				"weaver_ant"
			];
		}

		// Only the four controllers in the supplied ripening table are active.
		if rice_stage = "ripening" {
			return animal_agent.species_id in [
				"lynx_spider",
				"frog",
				"dragonfly",
				"snake"
			];
		}

		return false;
	}

	bool vu3_can_control(
		animal_template beneficial_agent,
		animal_template pest_agent
	) {

		string controller <- beneficial_agent.species_id;
		string pest <- pest_agent.species_id;
		string pest_life_stage <- pest_agent.life_stage;

		// Exact interaction table supplied for the vegetative stage.
		if rice_stage = "vegetative" {
			if controller = "trichogramma" {
				return pest = "leaf_folder" and pest_life_stage = "eggs";
			}

			if controller = "wasp" {
				return pest = "leaf_folder" and pest_life_stage = "larva";
			}

			if controller in ["lynx_spider", "frog", "dragonfly"] {
				return (pest = "brown_planthopper" and pest_life_stage = "nymph")
					or (pest = "leaf_folder" and pest_life_stage = "larva");
			}

			if controller in ["duck", "rat"] {
				return pest = "golden_apple_snail";
			}

			return false;
		}

		// Exact interaction table supplied for the reproductive stage.
		if rice_stage = "reproductive" {
			if controller = "trichogramma" {
				return (pest = "leaf_folder" and pest_life_stage = "eggs")
					or (pest = "yellow_stem_borer" and pest_life_stage = "eggs");
			}

			if controller = "wasp" {
				return (pest = "leaf_folder" and pest_life_stage = "larva")
					or (pest = "yellow_stem_borer" and pest_life_stage = "larva");
			}

			if controller in ["lynx_spider", "frog", "dragonfly"] {
				return (pest = "brown_planthopper" and pest_life_stage = "nymph")
					or (pest = "leaf_folder" and pest_life_stage = "larva")
					or (pest = "yellow_stem_borer" and pest_life_stage = "larva");
			}

			if controller = "weaver_ant" {
				return pest = "yellow_stem_borer"
					and pest_life_stage = "larva";
			}

			return false;
		}

		// Exact interaction table supplied for the ripening stage.
		if rice_stage = "ripening" {
			if controller in ["lynx_spider", "frog", "dragonfly"] {
				return pest = "brown_planthopper"
					and pest_life_stage = "nymph";
			}

			if controller = "snake" {
				return pest = "rat";
			}
		}

		return false;
	}

	action vu3_apply_pest_impact(animal_template pest_agent) {

		list<agent> rice_plants <- list(vegetative_rice_plant)
			+ list(reproductive_rice_plant)
			+ list(ripening_rice_plant);

		if !empty(rice_plants) {
			agent primary_rice <- nil;
			float closest_distance <- 1000000.0;

			loop rice_candidate over: rice_plants {
				float candidate_distance
					<- vu3_planar_distance(pest_agent, rice_candidate);

				if candidate_distance < closest_distance {
					closest_distance <- candidate_distance;
					primary_rice <- rice_candidate;
				}
			}

			if primary_rice != nil
				and closest_distance <= vu3_pest_attack_radius_m {

				string impact_type <- vu3_impact_type_for(pest_agent);
				float primary_intensity <- vu3_primary_impact_for(pest_agent);

				do vu3_record_rice_impact(
					primary_rice,
					impact_type,
					primary_intensity,
					true
				);

				loop neighbor_rice over: rice_plants {
					if neighbor_rice != primary_rice
						and vu3_planar_distance(neighbor_rice, primary_rice)
							<= vu3_neighbor_impact_radius_m {

						do vu3_record_rice_impact(
							neighbor_rice,
							impact_type,
							primary_intensity * vu3_neighbor_impact_factor,
							false
						);
					}
				}
			}
		}
	}

	string vu3_impact_type_for(animal_template pest_agent) {

		if pest_agent.species_id = "leaf_folder" {
			return "folds_leaves";
		}

		if pest_agent.species_id = "brown_planthopper" {
			return "sucks_sap";
		}

		if pest_agent.species_id = "yellow_stem_borer" {
			return "bores_stem";
		}

		if pest_agent.species_id = "golden_apple_snail" {
			return "eats_seedlings";
		}

		if pest_agent.species_id in ["rat", "bird"] {
			return "eats_grains";
		}

		return "general_pest_damage";
	}

	float vu3_primary_impact_for(animal_template pest_agent) {

		if pest_agent.species_id = "leaf_folder" {
			return 0.40;
		}

		if pest_agent.species_id = "brown_planthopper" {
			return 0.45;
		}

		if pest_agent.species_id = "yellow_stem_borer" {
			return 0.65;
		}

		if pest_agent.species_id = "golden_apple_snail" {
			return 0.55;
		}

		if pest_agent.species_id = "rat" {
			return 0.70;
		}

		if pest_agent.species_id = "bird" {
			return 0.50;
		}

		return 0.30;
	}

	action vu3_record_rice_impact(
		agent rice_agent,
		string impact_type_value,
		float impact_amount,
		bool is_primary_value
	) {

		list<rice_impact> existing_impacts
			<- rice_impact where (each.target_rice = rice_agent);

		if empty(existing_impacts) {
			create rice_impact number: 1 {
				target_rice <- rice_agent;
				impact_types <- [impact_type_value];
				impact_intensity <- min([1.0, impact_amount]);
				primary_impact <- is_primary_value;
				source_pest_count <- 1;
				location <- {
					rice_agent.location.x,
					rice_agent.location.y,
					0.0
				};
			}
		} else {
			ask first(existing_impacts) {
				impact_intensity <- min([1.0, impact_intensity + impact_amount]);
				primary_impact <- primary_impact or is_primary_value;
				source_pest_count <- source_pest_count + 1;

				if !(impact_type_value in impact_types) {
					impact_types << impact_type_value;
				}
			}
		}
	}
}

species rice_impact {

	agent target_rice;
	list<string> impact_types <- [];
	float impact_intensity <- 0.0;
	bool primary_impact <- false;
	int source_pest_count <- 0;

	rgb vu3_impact_color {

		if "bores_stem" in impact_types {
			return rgb(125, 45, 25);
		}

		if "eats_grains" in impact_types {
			return rgb(235, 145, 25);
		}

		if "eats_seedlings" in impact_types {
			return rgb(150, 65, 180);
		}

		if "folds_leaves" in impact_types {
			return rgb(235, 105, 35);
		}

		if "sucks_sap" in impact_types {
			return rgb(205, 35, 35);
		}

		return #red;
	}

	aspect default {

		rgb marker_color <- vu3_impact_color();
		float marker_size <- 0.25 + impact_intensity * 0.45;

		draw sphere(marker_size)
			at: {location.x, location.y, 0.65}
			color: rgb(marker_color, primary_impact ? 0.72 : 0.42);

		if vu3_show_impact_labels {
			draw string(impact_types)
				at: {location.x, location.y, 1.55}
				color: marker_color
				size: 0.28;
		}
	}
}
