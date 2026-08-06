model pest_damage_model

// Pest impacts are distinct agents created from pest-rice relationships.
import "vu2_config.gaml"
import "rice_model.gaml"
import "animal_model.gaml"

global {

	action validate_pest_damage_relation_data {
		pest_damage_relation_csv_is_valid <- true;

		if pest_damage_relation_data.rows <= 1 {
			write "pest_damage_relation.csv has no data rows.";
			pest_damage_relation_csv_is_valid <- false;
		}

		if string(pest_damage_relation_data[0, 0]) != "Pest"
			or string(pest_damage_relation_data[1, 0]) != "Rice Stage"
			or string(pest_damage_relation_data[2, 0]) != "Damage" {

			write "pest_damage_relation.csv headers must be Pest,Rice Stage,Damage.";
			pest_damage_relation_csv_is_valid <- false;
		}
	}

	string rice_stage_label(string stage_id) {
		if stage_id = "vegetative" {
			return "Vegetative Stage";
		}

		if stage_id = "reproductive" {
			return "Reproductive Stage";
		}

		return "Ripening Stage";
	}

	action clear_pest_impacts {
		ask pest_impact {
			do die;
		}
	}

	reflex create_pest_impacts when: enable_pest_impacts
		and pest_damage_relation_csv_is_valid
		and cycle mod pest_impact_update_interval_cycles = 0 {

		do clear_pest_impacts;

		string stage_label <- rice_stage_label(rice_stage);

		loop relation_row from: 1 to: pest_damage_relation_data.rows - 1 {
			string relation_pest_name <- string(pest_damage_relation_data[0, relation_row]);
			string relation_stage_label <- string(pest_damage_relation_data[1, relation_row]);
			string damage_prefab <- string(pest_damage_relation_data[2, relation_row]);

			if relation_stage_label = stage_label and damage_prefab != "" {
				if relation_pest_name = "Brown Planthopper" {
					ask brown_planthopper {
						string pest_key <- string(name);
						string pest_animal_id <- animal_id;
						string pest_species_name <- species_name;
						string pest_life_stage <- life_stage;
						point pest_location <- location;

						if rice_stage = "vegetative" {
							ask vegetative_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						} else if rice_stage = "reproductive" {
							ask reproductive_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						} else {
							ask ripening_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						}
					}
				} else if relation_pest_name = "Leaf Folder" {
					ask leaf_folder {
						string pest_key <- string(name);
						string pest_animal_id <- animal_id;
						string pest_species_name <- species_name;
						string pest_life_stage <- life_stage;
						point pest_location <- location;

						if rice_stage = "vegetative" {
							ask vegetative_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						} else if rice_stage = "reproductive" {
							ask reproductive_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						} else {
							ask ripening_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						}
					}
				} else if relation_pest_name = "Yellow Stem Borer" {
					ask yellow_stem_borer {
						string pest_key <- string(name);
						string pest_animal_id <- animal_id;
						string pest_species_name <- species_name;
						string pest_life_stage <- life_stage;
						point pest_location <- location;

						if rice_stage = "vegetative" {
							ask vegetative_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						} else if rice_stage = "reproductive" {
							ask reproductive_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						}
					}
				} else if relation_pest_name = "Golden Apple Snail" {
					ask golden_apple_snail {
						string pest_key <- string(name);
						string pest_animal_id <- animal_id;
						string pest_species_name <- species_name;
						string pest_life_stage <- life_stage;
						point pest_location <- location;

						if rice_stage = "vegetative" {
							ask vegetative_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						} else if rice_stage = "reproductive" {
							ask reproductive_rice_plant where (
								(each.location distance_to pest_location) <= default_pest_impact_radius_m
							) {
								string rice_id <- plant_id;
								point rice_location <- location;
								string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

								if length(pest_impact) < maximum_pest_impacts
									and empty(pest_impact where (each.interaction_key = key)) {
									create pest_impact number: 1 {
										interaction_key <- key;
										source_pest_id <- pest_animal_id;
										source_pest_name <- pest_species_name;
										source_pest_life_stage <- pest_life_stage;
										affected_rice_id <- rice_id;
										affected_rice_stage <- rice_stage;
										damage_prefab_name <- damage_prefab;
										location <- {
											rice_location.x + rnd(-0.12, 0.12),
											rice_location.y + rnd(-0.12, 0.12),
											rice_location.z + 0.18
										};
									}
								}
							}
						}
					}
				} else if relation_pest_name = "Rat" {
					ask rat {
						string pest_key <- string(name);
						string pest_animal_id <- animal_id;
						string pest_species_name <- species_name;
						string pest_life_stage <- life_stage;
						point pest_location <- location;

						ask ripening_rice_plant where (
							(each.location distance_to pest_location) <= default_pest_impact_radius_m
						) {
							string rice_id <- plant_id;
							point rice_location <- location;
							string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

							if length(pest_impact) < maximum_pest_impacts
								and empty(pest_impact where (each.interaction_key = key)) {
								create pest_impact number: 1 {
									interaction_key <- key;
									source_pest_id <- pest_animal_id;
									source_pest_name <- pest_species_name;
									source_pest_life_stage <- pest_life_stage;
									affected_rice_id <- rice_id;
									affected_rice_stage <- rice_stage;
									damage_prefab_name <- damage_prefab;
									location <- {
										rice_location.x + rnd(-0.12, 0.12),
										rice_location.y + rnd(-0.12, 0.12),
										rice_location.z + 0.18
									};
								}
							}
						}
					}
				} else if relation_pest_name = "Bird" {
					ask bird {
						string pest_key <- string(name);
						string pest_animal_id <- animal_id;
						string pest_species_name <- species_name;
						string pest_life_stage <- life_stage;
						point pest_location <- location;

						ask ripening_rice_plant where (
							(each.location distance_to pest_location) <= default_pest_impact_radius_m
						) {
							string rice_id <- plant_id;
							point rice_location <- location;
							string key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;

							if length(pest_impact) < maximum_pest_impacts
								and empty(pest_impact where (each.interaction_key = key)) {
								create pest_impact number: 1 {
									interaction_key <- key;
									source_pest_id <- pest_animal_id;
									source_pest_name <- pest_species_name;
									source_pest_life_stage <- pest_life_stage;
									affected_rice_id <- rice_id;
									affected_rice_stage <- rice_stage;
									damage_prefab_name <- damage_prefab;
									location <- {
										rice_location.x + rnd(-0.12, 0.12),
										rice_location.y + rnd(-0.12, 0.12),
										rice_location.z + 0.18
									};
								}
							}
						}
					}
				}
			}
		}
	}
}

species pest_impact {

	string interaction_key;
	string source_pest_id;
	string source_pest_name;
	string source_pest_life_stage;
	string affected_rice_id;
	string affected_rice_stage;
	string damage_prefab_name;
	agent source_pest_agent;
	float marker_height <- 1.65;
	float marker_radius <- 0.36;

	aspect default {
		point marker_base <- {
			location.x,
			location.y,
			location.z + 0.20
		};
		point marker_top <- {
			location.x,
			location.y,
			location.z + marker_height
		};

		draw rectangle(1.25, 1.25)
			at: marker_base
			rotate: 45.0
			color: rgb(210, 25, 25)
			border: #black;

		draw cylinder(0.07, marker_height)
			at: {
				location.x,
				location.y,
				location.z + marker_height / 2.0
			}
			color: rgb(230, 35, 25);

		draw sphere(marker_radius)
			at: marker_top
			color: rgb(255, 55, 35);

		draw circle(marker_radius * 1.8)
			at: marker_top
			color: rgb(#yellow, 0.45);

		if show_pest_damage_labels {
			draw "DAMAGE"
				at: {
					location.x,
					location.y,
					location.z + marker_height + 0.45
				}
				color: #red
				size: 0.55;
		}
	}
}
