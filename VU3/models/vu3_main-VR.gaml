model cropguard_vu3_vr

// Import the VU2 VR linker so later VU2 Unity mapping changes are inherited.
import "../../VU2/models/vu2_main-VR.gaml"
import "vu3_main.gaml"

species vu3_unity_linker parent: unity_linker {

	unity_property up_rice_impact;

	init {
		unity_aspect rice_impact_aspect
			<- geometry_aspect(0.8, #red, precision);

		up_rice_impact <- geometry_properties(
			"rice_impact",
			"impact",
			rice_impact_aspect,
			#no_interaction,
			false
		);

		unity_properties << up_rice_impact;
	}

	reflex send_vu3_impacts {
		do add_geometries_to_send(rice_impact, up_rice_impact);
	}
}

experiment vu3_vr parent: "vr_xp" autorun: false type: unity {

	string unity_linker_species <- string(vu3_unity_linker);

	list<string> displays_to_hide <- [
		"VU2",
		"VU3 Ecosystem",
		"Rice stage",
		"Rice plants",
		"Animal agents",
		"Pest agents",
		"Animal data records",
		"Field area m2",
		"VU3 active beneficial agents",
		"VU3 active pest agents",
		"Active impacted rice",
		"Pests controlled this cycle",
		"Total pests controlled",
		"BPH eggs laid this cycle",
		"Total BPH eggs laid",
		"Live BPH eggs on rice"
	];

	output {
		display VU3_VR parent: VU2_VR {
			species rice_impact aspect: default;
		}
	}
}
