model vu2_obj_diagnostic

global {
	init {
		create rice_model number: 1 {
			location <- {50.0, 50.0, 0.0};
		}
	}
}

species rice_model {
	aspect obj {
		draw obj_file("../fbx/gama/Plants/RicePlant_Vegetative.gama.obj", 90::{-1, 0, 0})
			at: location
			size: 15.0
			color: rgb(45, 175, 65);
	}
}

experiment diagnostic type: gui {
	output synchronized: true {

		// This display must work even when OBJ loading fails.
		display "1 - Primitives Only" type: 3d background: #black axes: false {
			camera 'default'
				location: {-34.826, 115.0892, 54.4789}
				target: {50.0, 50.0, 0.0};
			light #ambient intensity: 100;
			graphics world {
				draw world depth: 2.0 color: rgb(35, 110, 180);
				draw cube(10.0) at: {30.0, 50.0, 5.0} color: #red;
				draw sphere(7.0) at: {70.0, 50.0, 7.0} color: #yellow;
			}
		}

		// This is the same scene with one direct OBJ draw call added.
		display "2 - Rice OBJ" type: 3d background: #black axes: false {
			camera 'default'
				location: {-34.826, 115.0892, 54.4789}
				target: {50.0, 50.0, 0.0};
			light #ambient intensity: 100;
			graphics world {
				draw world depth: 2.0 color: rgb(35, 110, 180);
			}
			species rice_model aspect: obj;
		}
	}
}
