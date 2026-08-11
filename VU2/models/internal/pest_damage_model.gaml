model pest_damage_model

// Pest impacts are predefined by pest species and rice growth stage.
import "vu2_config.gaml"
import "rice_model.gaml"
import "animal_model.gaml"

global {

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
