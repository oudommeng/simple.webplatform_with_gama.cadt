model cropguard_rice_field_3d_corrected

// ============================================================================
// CropGuard - Rice Growth and Animal Observation Simulation
// ----------------------------------------------------------------------------
// This entry point intentionally stays small so collaborators can work in
// focused files without editing the same large model.
// ============================================================================

import "internal/vu2_config.gaml"
import "internal/field_model.gaml"
import "internal/rice_model.gaml"
import "internal/animal_model.gaml"
import "internal/vu2_gui_experiment.gaml"

global {

	init {
		do validate_animal_csv_data;
		do create_field_ground;
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

			do clear_rice_field;
			do create_rice_field;

			// The CSV contains different animal records for each rice stage.
			do clear_animals_for_stage_change;
			do create_animals_for_stage(rice_stage);
		}
	}
}
