# VU2 Model Includes

`vu2_main.gaml` is the entry point. Keep it focused on imports and top-level simulation flow.

- `vu2_config.gaml`: shared field, rice, CSV, density, and display settings.
- `field_model.gaml`: field-ground creation and display species.
- `rice_model.gaml`: rice-field creation, clearing, and rice plant species.
- `animal_model.gaml`: CSV-based animal creation, movement behavior, and animal species.
- `vu2_gui_experiment.gaml`: GUI parameters, display, and monitors.

When adding new behavior, prefer editing the most specific include file instead of `vu2_main.gaml`.

## Animal data

`animal_data.csv` is the original source and is retained for traceability. The
simulation now reads these normalized files:

- `animal_types.csv`: identity, taxonomy, ecological role, movement, speed, and
  Unity prefab metadata.
- `stage_populations.csv`: one explicit row per rice stage and animal type.
  `observed`, `absent`, and `not_sampled` have different meanings:
  `observed` means density and spawn points are present, `absent` means the
  species was sampled and not found, and `not_sampled` means no absence claim is
  supported by the source.
- `spawn_points.csv`: unique positions in the `gama_field_local_m` coordinate
  frame. Coordinates are in metres and fit inside `-17.5` to `17.5`.
- `data_sources.csv`: provenance for density and observation data.

Species density is stored once conceptually for a species and stage. Animal
life stages receive a fraction of that density. For the migrated baseline,
fractions are derived from each life stage's share of unique spawn points; the
`fraction_basis` and low confidence make this assumption visible.

The migration converts the legacy coordinate extent linearly into the local
field extent. Local coordinates use the field center as `{0,0}` and fit inside
`x_local_m` and `y_local_m` bounds of `-17.5` to `17.5`. Negative legacy
heights are treated as below-surface observations, so runtime `z_m` is clipped
to `0` while the original value is kept in `source_z`. Nine duplicated Brown
Planthopper locations are removed; use `spawn_weight` for any future intentional
weighted spawn location.

The Golden Apple Snail egg prefab is marked `missing` rather than borrowing the
Leaf Folder egg prefab. The Leaf Folder larva prefab remains configured but is
marked `needs_review` because its asset name contains `Nymph`.

The VR linker exports every GAMA animal species. Species that contain multiple
life stages currently use the adult prefab in VR because a single GAMA species
maps to one Unity property; their per-agent life-stage metadata is still kept in
`animal_types.csv`.

GAMA keeps the headers of `animal_types.csv` and `stage_populations.csv` in
their matrices because those files contain intentional empty metadata fields.
It recognizes and removes the fully populated `spawn_points.csv` header. The
loader's row bounds reflect this verified GAMA CSV behavior.

From the repository root, rebuild and validate the files with:

```sh
npm run prepare:vu2-data
npm run validate:vu2-data
```

The GAMA model also runs a lightweight CSV guard during `init`. If required
headers, statuses, densities, fractions, bounds, or spawn weights are invalid,
the model reports the issue and creates no animal agents.

Do not treat the current density values as field-validated measurements until
`data_sources.csv` contains a real source, sampling date, location, rice
variety, and sampling method.
