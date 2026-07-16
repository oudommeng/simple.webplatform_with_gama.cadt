# VU2 Model Includes

`vu2_main.gaml` is the entry point. Keep it focused on imports and top-level simulation flow.

- `vu2_config.gaml`: shared field, rice, CSV, density, and display settings.
- `field_model.gaml`: field-ground creation and display species.
- `rice_model.gaml`: rice-field creation, clearing, and rice plant species.
- `animal_model.gaml`: CSV-based animal creation, movement behavior, and animal species.
- `vu2_gui_experiment.gaml`: GUI parameters, display, and monitors.

When adding new behavior, prefer editing the most specific include file instead of `vu2_main.gaml`.
