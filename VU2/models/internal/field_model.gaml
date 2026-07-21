model field_model

global {

	action create_field_ground {
		create field_ground number: 1 {
			location <- {field_center_x, field_center_y, 0.0};
		}
	}
}

species field_ground {

	aspect default {
		draw rectangle(field_width + spacing, field_length + spacing)
			at: {location.x, location.y, -0.10}
			color: rgb(105, 145, 75)
			border: rgb(70, 100, 50);
	}
}
