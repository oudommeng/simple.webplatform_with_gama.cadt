model pest_damage_model

// Pest impacts are predefined by pest species and rice growth stage.
import "vu2_config.gaml"
import "rice_model.gaml"
import "animal_model.gaml"

global {

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

		if rice_stage = "vegetative" {
			ask brown_planthopper {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask vegetative_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create bph_vegetative_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"BPH_Vegetative_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask golden_apple_snail {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask vegetative_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create gas_vegetative_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"GAS_Vegetative_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask yellow_stem_borer {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask vegetative_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create ysb_vegetative_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"YSB_Vegetative_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask leaf_folder {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask vegetative_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create lf_vegetative_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"LF_Vegetative_Severe.prefab",
							rice_location
						);
					}
				}
			}
		} else if rice_stage = "reproductive" {
			ask brown_planthopper {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask reproductive_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create bph_reproductive_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"BPH_Reproductive_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask golden_apple_snail {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask reproductive_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create gas_reproductive_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"GAS_Reproductive_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask yellow_stem_borer {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask reproductive_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create ysb_reproductive_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"YSB_Reproductive_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask leaf_folder {
				string pest_key <- string(name);
				string pest_animal_id <- animal_id;
				string pest_species_name <- species_name;
				string pest_life_stage <- life_stage;
				point pest_location <- location;

				ask reproductive_rice_plant where (
					(each.location distance_to pest_location) <= default_pest_impact_radius_m
				) {
					string rice_id <- plant_id;
					point rice_location <- location;
					create lf_reproductive_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"LF_Reproductive_Severe.prefab",
							rice_location
						);
					}
				}
			}
		} else {
			ask brown_planthopper {
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
					create bph_ripening_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"BPH_Ripening_Severe.prefab",
							rice_location
						);
					}
				}
			}

			ask leaf_folder {
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
					create lf_ripening_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"LF_Ripening_Severe.prefab",
							rice_location
						);
					}
				}
			}

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
					create rat_ripening_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"R_Ripening.prefab",
							rice_location
						);
					}
				}
			}

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
					create bird_ripening_damage number: 1 {
						do setup_pest_impact(
							pest_key,
							pest_animal_id,
							pest_species_name,
							pest_life_stage,
							rice_id,
							"B_Ripening.prefab",
							rice_location
						);
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
	float marker_height <- 1.65;
	float marker_radius <- 0.36;
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
		string pest_key,
		string source_id,
		string source_name,
		string source_life_stage,
		string rice_id,
		string damage_prefab,
		point rice_location
	) {
		interaction_key <- pest_key + "|" + rice_id + "|" + rice_stage + "|" + damage_prefab;
		source_pest_id <- source_id;
		source_pest_name <- source_name;
		source_pest_life_stage <- source_life_stage;
		affected_rice_id <- rice_id;
		affected_rice_stage <- rice_stage;
		damage_prefab_name <- damage_prefab;
		damage_color <- damage_color_for_prefab(damage_prefab);
		location <- {
			rice_location.x + rnd(-0.12, 0.12),
			rice_location.y + rnd(-0.12, 0.12),
			rice_location.z + 0.18
		};
	}

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
			color: damage_color;

		draw circle(marker_radius * 1.8)
			at: marker_top
			color: rgb(#yellow, 0.45);

		if show_pest_damage_labels {
			draw source_pest_name + " damage"
				at: {
					location.x,
					location.y,
					location.z + marker_height + 0.45
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
