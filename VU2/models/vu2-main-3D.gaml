model cropguard_vu2_main_3D

// ============================================================================
// CropGuard VU2 - Native GAMA 3D asset view
// ----------------------------------------------------------------------------
// This entry point runs the same VU2 simulation as vu2_main.gaml, but displays
// the imported OBJ/MTL assets stored under ../fbx/.
// ============================================================================

import "internal/vu2_config.gaml"
import "internal/field_model.gaml"
import "internal/water_model.gaml"
import "internal/rice_model.gaml"
import "internal/animal_model.gaml"
import "internal/pest_damage_model.gaml"

global {

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

experiment vu2_main_3D type: gui {

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
