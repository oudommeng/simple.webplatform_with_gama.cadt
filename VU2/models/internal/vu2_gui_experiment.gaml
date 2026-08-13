model vu2_gui_experiment

// The GUI references VU2 configuration variables and every displayed species.
import "vu2_config.gaml"
import "field_model.gaml"
import "water_model.gaml"
import "rice_model.gaml"
import "animal_model.gaml"
import "pest_damage_model.gaml"

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
		step: 1000;

	parameter "Water adjustment rate"
		var: water_level_adjustment_rate
		min: 0.001
		max: 0.05
		step: 0.001;

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

	parameter "Pest impact update interval"
		var: pest_impact_update_interval_cycles
		min: 1
		max: 300
		step: 10;

	parameter "Pest impact radius"
		var: default_pest_impact_radius_m
		min: 0.10
		max: 5.00
		step: 0.10;

	parameter "Maximum pest impacts"
		var: maximum_pest_impacts
		min: 0
		max: 2000
		step: 50;

	parameter "Show pest labels"
		var: show_pest_labels;

	parameter "Show pest damage labels"
		var: show_pest_damage_labels;

	parameter "Show all animal labels"
		var: show_all_animal_labels;

	parameter "Show rice stage label"
		var: show_rice_labels;

	output {

		display "VU2"
			type: 3d
			background: rgb(210, 230, 240) {

			species field_ground aspect: default;
			species water aspect: default;
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
			species bph_vegetative_damage aspect: default;
			species bph_reproductive_damage aspect: default;
			species bph_ripening_damage aspect: default;
			species gas_vegetative_damage aspect: default;
			species gas_reproductive_damage aspect: default;
			species ysb_vegetative_damage aspect: default;
			species ysb_reproductive_damage aspect: default;
			species lf_vegetative_damage aspect: default;
			species lf_reproductive_damage aspect: default;
			species lf_ripening_damage aspect: default;
			species rat_ripening_damage aspect: default;
			species bird_ripening_damage aspect: default;

			graphics "Species legend" {
				draw "SPECIES LEGEND"
					at: {72.0, 102.0, 1.0}
					color: #black
					size: 1.0;

				draw triangle(0.90) at: {73.0, 97.5, 1.0} color: rgb(130, 75, 30);
				draw "Brown planthopper" at: {75.0, 97.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 93.5, 1.0} rotate: 45.0 color: rgb(225, 70, 45);
				draw "Leaf folder" at: {75.0, 93.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 89.5, 1.0} color: rgb(125, 55, 175);
				draw "Lynx spider" at: {75.0, 89.5, 1.0} color: #black size: 0.65;

				draw rectangle(1.20, 0.45) at: {73.0, 85.5, 1.0} color: rgb(245, 185, 25);
				draw "Trichogramma" at: {75.0, 85.5, 1.0} color: #black size: 0.65;

				draw triangle(0.90) at: {73.0, 81.5, 1.0} color: rgb(20, 175, 210);
				draw "Dragonfly" at: {75.0, 81.5, 1.0} color: #black size: 0.65;

				draw rectangle(1.20, 0.45) at: {73.0, 77.5, 1.0} color: rgb(225, 105, 155);
				draw "Worm" at: {75.0, 77.5, 1.0} color: #black size: 0.65;

				draw sphere(0.45) at: {73.0, 73.5, 1.0} color: rgb(45, 165, 70);
				draw "Frog" at: {75.0, 73.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 69.5, 1.0} color: rgb(235, 145, 20);
				draw "Yellow stem borer" at: {75.0, 69.5, 1.0} color: #black size: 0.65;

				draw sphere(0.45) at: {73.0, 65.5, 1.0} color: rgb(155, 135, 35);
				draw "Golden apple snail" at: {75.0, 65.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 61.5, 1.0} rotate: 45.0 color: rgb(65, 55, 35);
				draw "Wasp" at: {75.0, 61.5, 1.0} color: #black size: 0.65;

				draw rectangle(1.20, 0.45) at: {73.0, 57.5, 1.0} color: rgb(155, 35, 50);
				draw "Weaver ant" at: {75.0, 57.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 53.5, 1.0} rotate: 45.0 color: rgb(210, 60, 190);
				draw "Butterfly" at: {75.0, 53.5, 1.0} color: #black size: 0.65;

				draw sphere(0.45) at: {73.0, 49.5, 1.0} color: rgb(250, 115, 20);
				draw "Bee" at: {75.0, 49.5, 1.0} color: #black size: 0.65;

				draw triangle(0.90) at: {73.0, 45.5, 1.0} color: rgb(65, 120, 220);
				draw "Bird" at: {75.0, 45.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 41.5, 1.0} color: rgb(115, 115, 125);
				draw "Rat" at: {75.0, 41.5, 1.0} color: #black size: 0.65;

				draw sphere(0.45) at: {73.0, 37.5, 1.0} color: rgb(220, 30, 35);
				draw "Ladybug" at: {75.0, 37.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 33.5, 1.0} rotate: 45.0 color: rgb(30, 145, 135);
				draw "Duck" at: {75.0, 33.5, 1.0} color: #black size: 0.65;

				draw rectangle(1.20, 0.45) at: {73.0, 29.5, 1.0} color: rgb(35, 105, 45);
				draw "Snake" at: {75.0, 29.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 25.5, 1.0} color: rgb(105, 70, 45);
				draw "Cricket" at: {75.0, 25.5, 1.0} color: #black size: 0.65;

				draw rectangle(0.90, 0.90) at: {73.0, 21.5, 1.0} rotate: 45.0 color: rgb(30, 85, 190);
				draw "Fish" at: {75.0, 21.5, 1.0} color: #black size: 0.65;

				draw sphere(0.45) at: {73.0, 17.5, 1.0} color: rgb(255, 55, 35);
				draw circle(0.80) at: {73.0, 17.5, 1.0} color: rgb(#yellow, 0.45);
				draw "Pest damage" at: {75.0, 17.5, 1.0} color: #black size: 0.65;
			}
		}

		monitor "Rice stage"
			value: rice_stage;

		monitor "Water level"
			value: water_level;

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

		monitor "Pest impacts"
			value: pest_impact_count();

		monitor "Animal data records"
			value: animal_types_data.rows - 1
				+ stage_populations_data.rows - 1
				+ spawn_points_data.rows;

		monitor "Field area m2"
			value: field_area_m2;
	}
}
