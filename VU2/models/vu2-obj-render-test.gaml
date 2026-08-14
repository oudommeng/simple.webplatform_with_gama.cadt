model vu2_obj_render_test

// Minimal standalone OBJ rendering test for GAMA.
// The OBJ and its MTL file are stored together under ../fbx/gama/Plants/.

global {
	geometry shape <- square(30.0);
	string rice_obj_path <- "../fbx/gama/Plants/RicePlant_Vegetative.gama.obj";

	init {
		create obj_rice number: 1 {
			location <- {15.0, 15.0, 0.0};
		}
	}
}

species obj_rice {

	aspect obj3d {
		draw obj_file(rice_obj_path, 90::{-1, 0, 0})
			at: location
			size: 8.0
			color: rgb(45, 175, 65);
	}
}

experiment obj_render_test type: gui {

	output synchronized: true {
		display "OBJ Render Test"
			type: 3d
			background: rgb(210, 230, 240) {

			camera 'default'
				location: {15.0, 42.0, 24.0}
				target: {15.0, 15.0, 2.0};

			light #ambient intensity: 200;

			graphics "reference" {
				draw rectangle(30.0, 30.0)
					at: {15.0, 15.0, -0.1}
					color: rgb(95, 135, 75)
					border: #darkgreen;

				// Large primitive markers remain visible even if OBJ loading fails.
				draw cube(3.0)
					at: {5.0, 5.0, 1.5}
					color: #red;
				draw cube(3.0)
					at: {25.0, 5.0, 1.5}
					color: #green;
				draw cube(3.0)
					at: {5.0, 25.0, 1.5}
					color: #blue;
			}

			species obj_rice aspect: obj3d;
		}
	}
}
