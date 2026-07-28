model vu2_gui_experiment

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

		monitor "Animal data records"
			value: animal_types_data.rows - 1
				+ stage_populations_data.rows - 1
				+ spawn_points_data.rows;

		monitor "Field area m2"
			value: field_area_m2;
	}
}
