model cropguard_rice_field_3d_corrected_model_VR

import "vu2_main.gaml"

species unity_linker parent: abstract_unity_linker {
	string player_species <- string(unity_player);
	int max_num_players  <- 6;
	unity_property up_wasp;
	unity_property up_default;
	unity_property up_ripening_rice_plant;
	unity_property up_vegetative_rice_plant;
	unity_property up_reproductive_rice_plant;
	unity_property up_frog;
	list<point> init_locations <- define_init_locations();

	list<point> define_init_locations {
		return [{50.0,50.0,0.0},{50.0,50.0,0.0},{50.0,50.0,0.0},{50.0,50.0,0.0},{50.0,50.0,0.0},{50.0,50.0,0.0}];
	}


	init {
		do define_properties;
		player_unity_properties <- [nil,nil,nil,nil,nil,nil];
	}
	action define_properties {
		unity_aspect wasp_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Wasp_01",1.0,0.0,1.0,0.0,precision);
		up_wasp <- geometry_properties("wasp","animal",wasp_aspect,#grabable,false);
		unity_properties << up_wasp;


		unity_aspect default_aspect <- geometry_aspect(1.0,#gray,precision);
		up_default <- geometry_properties("default","",default_aspect,#no_interaction,false);
		unity_properties << up_default;


		unity_aspect ripening_rice_plant_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Plants/SM_RiceCrop_Rippening",1.0,0.0,1.0,0.0,precision);
		up_ripening_rice_plant <- geometry_properties("ripening_rice_plant","rice",ripening_rice_plant_aspect,#ray_interactable,false);
		unity_properties << up_ripening_rice_plant;


		unity_aspect vegetative_rice_plant_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Plants/SM_RiceCrop_Vegetative",1.0,0.0,1.0,0.0,precision);
		up_vegetative_rice_plant <- geometry_properties("vegetative_rice_plant","rice",vegetative_rice_plant_aspect,#ray_interactable,false);
		unity_properties << up_vegetative_rice_plant;


		unity_aspect reproductive_rice_plant_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Plants/SM_RiceCrop_Reproductive",1.0,0.0,1.0,0.0,precision);
		up_reproductive_rice_plant <- geometry_properties("reproductive_rice_plant","rice",reproductive_rice_plant_aspect,#ray_interactable,false);
		unity_properties << up_reproductive_rice_plant;


		unity_aspect frog_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Frog_01",1.0,0.0,1.0,0.0,precision);
		up_frog <- geometry_properties("frog","animal",frog_aspect,#grabable,false);
		unity_properties << up_frog;

	}
	reflex send_geometries {
		do add_geometries_to_send(wasp,up_wasp);
		do add_geometries_to_send(frog,up_frog);
		do add_geometries_to_send(ripening_rice_plant,up_ripening_rice_plant);
		do add_geometries_to_send(reproductive_rice_plant,up_reproductive_rice_plant);
		do add_geometries_to_send(vegetative_rice_plant,up_vegetative_rice_plant);
	}
}

species unity_player parent: abstract_unity_player{
	float player_size <- 1.0;
	rgb color <- #red;
	float cone_distance <- 10.0 * player_size;
	float cone_amplitude <- 90.0;
	float player_rotation <- 90.0;
	bool to_display <- true;
	float z_offset <- 2.0;
	aspect default {
		if to_display {
			if selected {
				 draw circle(player_size) at: location + {0, 0, z_offset} color: rgb(#blue, 0.5);
			}
			draw circle(player_size/2.0) at: location + {0, 0, z_offset} color: color ;
			draw player_perception_cone() color: rgb(color, 0.5);
		}
	}
}

experiment vr_xp parent:"vu2" autorun: false type: unity {
	float minimum_cycle_duration <- 0.1;
	string unity_linker_species <- string(unity_linker);
	list<string> displays_to_hide <- ["VU2","Rice stage","Rice plants","Animal agents","Pest agents","CSV rows","Field area m2","VU2","Rice stage","Rice plants","Animal agents","Pest agents","CSV rows","Field area m2"];
	float t_ref;

	action create_player(string id) {
		ask unity_linker {
			do create_player(id);
		}
	}

	action remove_player(string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}
		}
	}

	output {
		 display VU2_VR parent:VU2{
			 species unity_player;
			 event #mouse_down{
				 float t <- gama.machine_time;
				 if (t - t_ref) > 500 {
					 ask unity_linker {
						 move_player_event <- true;
					 }
					 t_ref <- t;
				 }
			 }
		 }
	}
}
