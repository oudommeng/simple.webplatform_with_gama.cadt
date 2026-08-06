model water_model

// Water level follows the active rice growth stage and changes smoothly.
import "vu2_config.gaml"

global {

	float water_level_for_stage(string stage) {
		if stage = "vegetative" {
			return vegetative_water_level;
		}

		if stage = "reproductive" {
			return reproductive_water_level;
		}

		return ripening_water_level;
	}

	action update_water_target_for_stage {
		target_water_level <- water_level_for_stage(rice_stage);
	}

	action create_water_surface {
		do update_water_target_for_stage;

		if empty(water) {
			create water number: 1 {
				location <- {field_center_x, field_center_y, water_level};
			}
		}
	}

	reflex adjust_water_level {
		do update_water_target_for_stage;

		float level_delta <- target_water_level - water_level;

		if abs(level_delta) <= water_level_adjustment_rate {
			water_level <- target_water_level;
		} else if level_delta > 0.0 {
			water_level <- water_level + water_level_adjustment_rate;
		} else {
			water_level <- water_level - water_level_adjustment_rate;
		}

		ask water {
			location <- {field_center_x, field_center_y, water_level};
			depth <- water_level;
		}
	}
}

species water {

	float depth <- water_level;

	aspect default {
		draw rectangle(field_width + spacing, field_length + spacing)
			at: {location.x, location.y, depth}
			color: rgb(rgb(55, 135, 210), 0.40)
			border: rgb(35, 95, 165);
	}
}
