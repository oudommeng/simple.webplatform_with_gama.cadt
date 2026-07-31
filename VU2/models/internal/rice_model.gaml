model rice_model

// Rice creation and rendering use the shared field and stage configuration.
import "vu2_config.gaml"

global {

	action clear_rice_field {
		ask vegetative_rice_plant {
			do die;
		}
		ask reproductive_rice_plant {
			do die;
		}
		ask ripening_rice_plant {
			do die;
		}
	}

	action create_rice_field {
		loop c from: 0 to: nb_cols - 1 {
			loop r from: 0 to: nb_rows - 1 {
				float px <- field_min_x + c * spacing;
				float py <- field_min_y + r * spacing;

				if rice_stage = "vegetative" {
					create vegetative_rice_plant number: 1 {
						plant_id <- "R_" + string(c) + "_" + string(r);
						grid_col <- c;
						grid_row <- r;
						location <- {px, py, 0.0};
					}
				} else if rice_stage = "reproductive" {
					create reproductive_rice_plant number: 1 {
						plant_id <- "R_" + string(c) + "_" + string(r);
						grid_col <- c;
						grid_row <- r;
						location <- {px, py, 0.0};
					}
				} else {
					create ripening_rice_plant number: 1 {
						plant_id <- "R_" + string(c) + "_" + string(r);
						grid_col <- c;
						grid_row <- r;
						location <- {px, py, 0.0};
					}
				}
			}
		}
	}
}

species vegetative_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.00;
	float canopy_size <- 0.38;

	aspect default {
		draw cylinder(0.07, plant_height)
			at: {location.x, location.y, plant_height / 2.0}
			color: rgb(55, 165, 65);

		draw sphere(canopy_size)
			at: {location.x, location.y, plant_height * 0.70}
			color: rgb(55, 165, 65);

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "vegetative"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}
}

species reproductive_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.45;
	float canopy_size <- 0.48;

	aspect default {
		draw cylinder(0.07, plant_height)
			at: {location.x, location.y, plant_height / 2.0}
			color: rgb(75, 155, 60);

		draw sphere(canopy_size)
			at: {location.x, location.y, plant_height * 0.70}
			color: rgb(75, 155, 60);

		draw sphere(0.14)
			at: {location.x, location.y, plant_height + 0.08}
			color: rgb(190, 205, 90);

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "reproductive"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}
}

species ripening_rice_plant {

	string plant_id;
	int grid_col;
	int grid_row;
	float plant_height <- 1.70;
	float canopy_size <- 0.52;

	aspect default {
		draw cylinder(0.07, plant_height)
			at: {location.x, location.y, plant_height / 2.0}
			color: rgb(145, 160, 55);

		draw sphere(canopy_size)
			at: {location.x, location.y, plant_height * 0.70}
			color: rgb(145, 160, 55);

		draw sphere(0.14)
			at: {location.x, location.y, plant_height + 0.08}
			color: rgb(225, 185, 55);

		if show_rice_labels and grid_col = 0 and grid_row = 0 {
			draw "ripening"
				at: {location.x, location.y, plant_height + 0.50}
				color: #black
				size: 0.45;
		}
	}
}
