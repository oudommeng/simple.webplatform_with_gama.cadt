model cropguard_rice_field_3d_corrected_model_VR

import "vu2_main.gaml"

species unity_linker parent: abstract_unity_linker {
	string player_species <- string(unity_player);
	int max_num_players  <- 6;
	unity_property up_brown_planthopper;
	unity_property up_leaf_folder;
	unity_property up_lynx_spider;
	unity_property up_trichogramma;
	unity_property up_dragonfly;
	unity_property up_worm;
	unity_property up_wasp;
	unity_property up_weaver_ant;
	unity_property up_butterfly;
	unity_property up_bee;
	unity_property up_bird;
	unity_property up_rat;
	unity_property up_ladybug;
	unity_property up_duck;
	unity_property up_snake;
	unity_property up_cricket;
	unity_property up_fish;
	unity_property up_yellow_stem_borer;
	unity_property up_golden_apple_snail;
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
		unity_aspect brown_planthopper_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_BrownPlantHopper_01",1.0,0.0,1.0,0.0,precision);
		up_brown_planthopper <- geometry_properties("brown_planthopper","animal",brown_planthopper_aspect,#grabable,false);
		unity_properties << up_brown_planthopper;

		unity_aspect leaf_folder_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_GreenLeafFolder_01",1.0,0.0,1.0,0.0,precision);
		up_leaf_folder <- geometry_properties("leaf_folder","animal",leaf_folder_aspect,#grabable,false);
		unity_properties << up_leaf_folder;

		unity_aspect lynx_spider_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Spider_01",1.0,0.0,1.0,0.0,precision);
		up_lynx_spider <- geometry_properties("lynx_spider","animal",lynx_spider_aspect,#grabable,false);
		unity_properties << up_lynx_spider;

		unity_aspect trichogramma_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Trichogramma_01",1.0,0.0,1.0,0.0,precision);
		up_trichogramma <- geometry_properties("trichogramma","animal",trichogramma_aspect,#grabable,false);
		unity_properties << up_trichogramma;

		unity_aspect dragonfly_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Dragonfly_01",1.0,0.0,1.0,0.0,precision);
		up_dragonfly <- geometry_properties("dragonfly","animal",dragonfly_aspect,#grabable,false);
		unity_properties << up_dragonfly;

		unity_aspect worm_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Worm_01",1.0,0.0,1.0,0.0,precision);
		up_worm <- geometry_properties("worm","animal",worm_aspect,#grabable,false);
		unity_properties << up_worm;

		unity_aspect wasp_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Wasp_01",1.0,0.0,1.0,0.0,precision);
		up_wasp <- geometry_properties("wasp","animal",wasp_aspect,#grabable,false);
		unity_properties << up_wasp;

		unity_aspect weaver_ant_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_WeaverAnt_01",1.0,0.0,1.0,0.0,precision);
		up_weaver_ant <- geometry_properties("weaver_ant","animal",weaver_ant_aspect,#grabable,false);
		unity_properties << up_weaver_ant;

		unity_aspect butterfly_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Butterfly_01",1.0,0.0,1.0,0.0,precision);
		up_butterfly <- geometry_properties("butterfly","animal",butterfly_aspect,#grabable,false);
		unity_properties << up_butterfly;

		unity_aspect bee_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Bee_01",1.0,0.0,1.0,0.0,precision);
		up_bee <- geometry_properties("bee","animal",bee_aspect,#grabable,false);
		unity_properties << up_bee;

		unity_aspect bird_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Bird_01",1.0,0.0,1.0,0.0,precision);
		up_bird <- geometry_properties("bird","animal",bird_aspect,#grabable,false);
		unity_properties << up_bird;

		unity_aspect rat_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Rat_01",1.0,0.0,1.0,0.0,precision);
		up_rat <- geometry_properties("rat","animal",rat_aspect,#grabable,false);
		unity_properties << up_rat;

		unity_aspect ladybug_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Ladybug_01",1.0,0.0,1.0,0.0,precision);
		up_ladybug <- geometry_properties("ladybug","animal",ladybug_aspect,#grabable,false);
		unity_properties << up_ladybug;

		unity_aspect duck_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Duck_01",1.0,0.0,1.0,0.0,precision);
		up_duck <- geometry_properties("duck","animal",duck_aspect,#grabable,false);
		unity_properties << up_duck;

		unity_aspect snake_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Snake_01",1.0,0.0,1.0,0.0,precision);
		up_snake <- geometry_properties("snake","animal",snake_aspect,#grabable,false);
		unity_properties << up_snake;

		unity_aspect cricket_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Cricket_01",1.0,0.0,1.0,0.0,precision);
		up_cricket <- geometry_properties("cricket","animal",cricket_aspect,#grabable,false);
		unity_properties << up_cricket;

		unity_aspect fish_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_Fish_01",1.0,0.0,1.0,0.0,precision);
		up_fish <- geometry_properties("fish","animal",fish_aspect,#grabable,false);
		unity_properties << up_fish;

		unity_aspect yellow_stem_borer_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_YellowStemBorer_01",1.0,0.0,1.0,0.0,precision);
		up_yellow_stem_borer <- geometry_properties("yellow_stem_borer","animal",yellow_stem_borer_aspect,#grabable,false);
		unity_properties << up_yellow_stem_borer;

		unity_aspect golden_apple_snail_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Prefabs/Animals/SM_GoldenAppleSnail_01",1.0,0.0,1.0,0.0,precision);
		up_golden_apple_snail <- geometry_properties("golden_apple_snail","animal",golden_apple_snail_aspect,#grabable,false);
		unity_properties << up_golden_apple_snail;

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
		do add_geometries_to_send(brown_planthopper,up_brown_planthopper);
		do add_geometries_to_send(leaf_folder,up_leaf_folder);
		do add_geometries_to_send(lynx_spider,up_lynx_spider);
		do add_geometries_to_send(trichogramma,up_trichogramma);
		do add_geometries_to_send(dragonfly,up_dragonfly);
		do add_geometries_to_send(worm,up_worm);
		do add_geometries_to_send(wasp,up_wasp);
		do add_geometries_to_send(weaver_ant,up_weaver_ant);
		do add_geometries_to_send(butterfly,up_butterfly);
		do add_geometries_to_send(bee,up_bee);
		do add_geometries_to_send(bird,up_bird);
		do add_geometries_to_send(rat,up_rat);
		do add_geometries_to_send(ladybug,up_ladybug);
		do add_geometries_to_send(duck,up_duck);
		do add_geometries_to_send(snake,up_snake);
		do add_geometries_to_send(cricket,up_cricket);
		do add_geometries_to_send(fish,up_fish);
		do add_geometries_to_send(yellow_stem_borer,up_yellow_stem_borer);
		do add_geometries_to_send(golden_apple_snail,up_golden_apple_snail);
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
	list<string> displays_to_hide <- ["VU2","Rice stage","Rice plants","Animal agents","Pest agents","Animal data records","Field area m2"];
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
