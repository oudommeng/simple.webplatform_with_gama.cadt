model vu3_gui_experiment

experiment vu3 parent: "vu2" type: gui {

	parameter "Enable VU3 interactions"
		var: vu3_interactions_enabled;

	parameter "Pest attack radius (m)"
		var: vu3_pest_attack_radius_m
		min: 0.25
		max: 5.0
		step: 0.05;

	parameter "Neighbor impact radius (m)"
		var: vu3_neighbor_impact_radius_m
		min: 0.0
		max: 9.0
		step: 0.10;

	parameter "Beneficial control radius (m)"
		var: vu3_beneficial_control_radius_m
		min: 0.25
		max: 8.0
		step: 0.05;

	parameter "Beneficial success probability"
		var: vu3_beneficial_success_probability
		min: 0.0
		max: 1.0
		step: 0.05;

	parameter "Neighbor impact factor"
		var: vu3_neighbor_impact_factor
		min: 0.0
		max: 1.0
		step: 0.05;

	parameter "Enable Brown Planthopper egg laying"
		var: vu3_bph_egg_laying_enabled;

	parameter "BPH egg-laying contact radius (m)"
		var: vu3_bph_egg_laying_radius_m
		min: 0.10
		max: 2.0
		step: 0.05;

	parameter "BPH egg-laying probability"
		var: vu3_bph_egg_laying_probability
		min: 0.0
		max: 1.0
		step: 0.05;

	parameter "BPH egg-laying cooldown (cycles)"
		var: vu3_bph_egg_laying_cooldown_cycles
		min: 1
		max: 600
		step: 1;

	parameter "Maximum eggs per BPH adult"
		var: vu3_bph_max_eggs_per_adult
		min: 1
		max: 20
		step: 1;

	parameter "Maximum BPH eggs per rice"
		var: vu3_bph_max_eggs_per_rice
		min: 1
		max: 50
		step: 1;

	parameter "Show impact labels"
		var: vu3_show_impact_labels;

	output {

		display "VU3 Ecosystem"
			parent: "VU2" {

			species rice_impact aspect: default;
		}

		monitor "VU3 active beneficial agents"
			value: length(
				(agents of_generic_species animal_template) where (
					(
						rice_stage = "vegetative"
						and each.species_id in [
							"trichogramma",
							"wasp",
							"lynx_spider",
							"frog",
							"dragonfly",
							"duck",
							"rat"
						]
					)
					or (
						rice_stage = "reproductive"
						and each.species_id in [
							"trichogramma",
							"wasp",
							"lynx_spider",
							"frog",
							"dragonfly",
							"weaver_ant"
						]
					)
					or (
						rice_stage = "ripening"
						and each.species_id in [
							"lynx_spider",
							"frog",
							"dragonfly",
							"snake"
						]
					)
				)
			);

		monitor "VU3 active pest agents"
			value: length(
				(agents of_generic_species animal_template) where (
					(
						rice_stage = "vegetative"
						and each.species_id in [
							"brown_planthopper",
							"leaf_folder",
							"golden_apple_snail"
						]
					)
					or (
						rice_stage = "reproductive"
						and each.species_id in [
							"brown_planthopper",
							"leaf_folder",
							"yellow_stem_borer"
						]
					)
					or (
						rice_stage = "ripening"
						and each.species_id in [
							"brown_planthopper",
							"rat",
							"bird"
						]
					)
				)
			);

		monitor "Active impacted rice"
			value: length(rice_impact);

		monitor "Pests controlled this cycle"
			value: vu3_pests_controlled_this_cycle;

		monitor "Total pests controlled"
			value: vu3_total_pests_controlled;

		monitor "BPH eggs laid this cycle"
			value: vu3_bph_eggs_laid_this_cycle;

		monitor "Total BPH eggs laid"
			value: vu3_total_bph_eggs_laid;

		monitor "Live BPH eggs on rice"
			value: length(
				brown_planthopper where (
					each.life_stage = "eggs"
						and each.spawned_by_reproduction
				)
			);
	}
}
