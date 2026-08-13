# VU2 Simulation - Key Data Structures

## 1. FIELD CONFIGURATION

```
FIELD PARAMETERS (vu2_config.gaml):
┌─────────────────────────────────────────┐
│ Field Center Point                      │
│ ├─ field_center_x = 50.0                │
│ ├─ field_center_y = 50.0                │
│ └─ Z plane = 0.0 (ground level)         │
├─────────────────────────────────────────┤
│ Grid Dimensions                         │
│ ├─ nb_cols = 13                         │
│ ├─ nb_rows = 13                         │
│ ├─ spacing = 3.0 meters                 │
│ └─ Total Plants = 169                   │
├─────────────────────────────────────────┤
│ Calculated Bounds                       │
│ ├─ field_min_x = 31.0                   │
│ ├─ field_max_x = 69.0                   │
│ ├─ field_min_y = 31.0                   │
│ ├─ field_max_y = 69.0                   │
│ ├─ field_width = 39 meters              │
│ ├─ field_length = 39 meters             │
│ └─ field_area_m2 = 1521.0 m²            │
└─────────────────────────────────────────┘

WORLD ENVELOPE: 110×110 meter box (centered at 50,50)
```

## 2. RICE PLANT DATA STRUCTURE

```
RICE PLANT OBJECT (Species):
┌──────────────────────────────────────────────────┐
│ plant_id = "R_<col>_<row>"                       │
│ example: "R_0_5"                                 │
├──────────────────────────────────────────────────┤
│ Spatial Data                                     │
│ ├─ location.x ∈ [31, 69]                         │
│ ├─ location.y ∈ [31, 69]                         │
│ └─ location.z = 0.0 (ground)                     │
├──────────────────────────────────────────────────┤
│ Grid Index                                       │
│ ├─ grid_col ∈ [0, 12]                            │
│ └─ grid_row ∈ [0, 12]                            │
├──────────────────────────────────────────────────┤
│ VEGETATIVE STAGE                                 │
│ ├─ plant_height = 1.00 m                         │
│ ├─ canopy_size = 0.38 m                          │
│ ├─ color = RGB(55, 165, 65)  [Dark Green]       │
│ └─ 3D: Cylinder + Sphere                         │
├──────────────────────────────────────────────────┤
│ REPRODUCTIVE STAGE                               │
│ ├─ plant_height = 1.45 m                         │
│ ├─ canopy_size = 0.48 m                          │
│ ├─ panicle_size = 0.14 m  [grain heads]         │
│ ├─ color = RGB(75, 155, 60) [Medium Green]      │
│ └─ 3D: Cylinder + Sphere + Sphere                │
├──────────────────────────────────────────────────┤
│ RIPENING STAGE                                   │
│ ├─ plant_height = 1.70 m                         │
│ ├─ canopy_size = 0.52 m                          │
│ ├─ grain_color = RGB(225, 185, 55) [Golden]    │
│ ├─ color = RGB(145, 160, 55) [Yellow-Green]    │
│ └─ 3D: Cylinder + Sphere + Sphere                │
└──────────────────────────────────────────────────┘

PER-STAGE PLANT CREATION (169 times each):
vegetation
for c in 0..12:
  for r in 0..12:
    px = field_min_x + c * spacing = [31, 69]
    py = field_min_y + r * spacing = [31, 69]
    create plant at (px, py, 0)
```

## 3. ANIMAL CSV DATA STRUCTURE

```
ANIMAL_DATA.CSV MATRIX FORMAT:
┌─────────────────────────────────────────────────────────────────┐
│ Row 0: HEADER                                                   │
├─────────────────────────────────────────────────────────────────┤
│ Col[0] = "rice_stage"          ▶ "vegetative"/"reproductive"   │
│ Col[1] = "stage_name"          ▶ "V1", "V2", "R1", etc         │
│ Col[2] = "animal_id"           ▶ "BPH", "LF", "YSB", etc       │
│ Col[3] = "animal_name"         ▶ "Brown Planthopper", etc      │
│ Col[4] = "species_name"        ▶ Full species name             │
│ Col[5] = "life_stage"          ▶ "egg", "nymph", "adult", etc  │
│ Col[6] = "prefab_name"         ▶ 3D model name                 │
│ Col[7] = "prefab_path"         ▶ Path to model asset           │
│ Col[8] = "density_per_100m2"   ▶ Float (population per 100m²)  │
│ Col[9] = "unknown"             ▶ (reserved/unused)             │
│ Col[10] = "csv_x"              ▶ Float (X offset from center)  │
│ Col[11] = "csv_y"              ▶ Float (Y offset from center)  │
│ Col[12] = "csv_z"              ▶ Float (height offset)         │
└─────────────────────────────────────────────────────────────────┘

EXAMPLE ROWS:
┌──────┬───────────┬─────┬─────────────┬──────────────┬───────┬─────────────┬────────────┬─────────┬────────┬────────┬────────┬────────┐
│ rice │  stage    │ aid │ animal_name │ species_name │ stage │ prefab_name │  prefab   │ density │ unused │ csv_x  │ csv_y  │ csv_z  │
├──────┼───────────┼─────┼─────────────┼──────────────┼───────┼─────────────┼────────────┼─────────┼────────┼────────┼────────┼────────┤
│ veg  │ V1        │ BPH │ Brown Ph... │ Brown Pl...  │ nymph │ BPH_nymph   │ /models/BPH│ 15.0   │        │ 5.0    │ 2.0    │ 0.3    │
│ veg  │ V1        │ LF  │ Leaf Folder │ Leaf Fol...  │ adult │ LF_adult    │ /models/LF │ 8.5    │        │ -3.0   │ 4.5    │ 0.5    │
│ repr │ R1        │ BPH │ Brown Ph... │ Brown Pl...  │ adult │ BPH_adult   │ /models/BPH│ 25.0   │        │ 0.0    │ 0.0    │ 0.8    │
│ repr │ R1        │ LynxS│ Lynx Spider│ Oxyopes ...  │ adult │ LynxSpider  │ /models/LS │ 2.0    │        │ -2.0   │ -1.0   │ 1.5    │
└──────┴───────────┴─────┴─────────────┴──────────────┴───────┴─────────────┴────────────┴─────────┴────────┴────────┴────────┴────────┘
```

## 4. ANIMAL OBJECT DATA STRUCTURE

```
ANIMAL_TEMPLATE BASE CLASS:
┌──────────────────────────────────────────────────────────┐
│ Identity (from CSV)                                      │
│ ├─ stage_id = "V1" / "R1" / "Rip1"                       │
│ ├─ stage_name = <string from csv[1]>                     │
│ ├─ animal_id = "BPH" / "LF" / "YSB" / etc               │
│ ├─ animal_name = "Brown Planthopper" / etc               │
│ ├─ species_name = full scientific name                   │
│ ├─ life_stage = "egg" / "nymph" / "larva" / "adult"     │
│ ├─ prefab_name = 3D model identifier                     │
│ └─ prefab_path = path to 3D asset                        │
├──────────────────────────────────────────────────────────┤
│ Spatial State                                            │
│ ├─ location.x ∈ [31±0.4, 69±0.4]                         │
│ ├─ location.y ∈ [31±0.4, 69±0.4]                         │
│ ├─ location.z = height(movement_mode, csv_z)            │
│ └─ heading = movement direction (radians)               │
├──────────────────────────────────────────────────────────┤
│ Classification                                           │
│ ├─ is_pest = true/false (from pest_species list)        │
│ └─ density_per_100m2 = float from CSV                    │
├──────────────────────────────────────────────────────────┤
│ Movement Behavior                                        │
│ ├─ movement_mode ∈ {ground, fly, swim, stationary}      │
│ ├─ movement_speed = 0.08 (default, varies by mode)       │
│ ├─ has_movement_heading = true/false                     │
│ ├─ movement_destination = point (or stationary)         │
│ └─ destination_timer = cycles until recalculate         │
├──────────────────────────────────────────────────────────┤
│ Species-Specific (Each Subclass)                         │
│ ├─ brown_planthopper                                     │
│ ├─ leaf_folder                                           │
│ ├─ lynx_spider                                           │
│ ├─ trichogramma                                          │
│ ├─ dragonfly                                             │
│ ├─ worm                                                  │
│ ├─ frog                                                  │
│ ├─ yellow_stem_borer                                     │
│ ├─ golden_apple_snail                                    │
│ ├─ wasp                                                  │
│ ├─ weaver_ant                                            │
│ ├─ butterfly                                             │
│ ├─ bee                                                   │
│ ├─ bird                                                  │
│ ├─ rat                                                   │
│ ├─ ladybug                                               │
│ ├─ duck                                                  │
│ ├─ snake                                                 │
│ ├─ cricket                                               │
│ └─ fish                                                  │
└──────────────────────────────────────────────────────────┘

MOVEMENT MODE DETERMINATION:
┌─────────────────────────────────────────────────────────┐
│ Function: get_movement_mode(species, life_stage)        │
├─────────────────────────────────────────────────────────┤
│ IF life_stage contains "egg" or "pupa"                  │
│    ▶ STATIONARY (no movement)                            │
├─────────────────────────────────────────────────────────┤
│ ELSE IF species in flying_insects or birds or dragonfly │
│    ▶ FLY (3D aerial movement, z ∈ [0.5, 3.0])           │
├─────────────────────────────────────────────────────────┤
│ ELSE IF species in aquatic (fish, frog, duck)           │
│    ▶ SWIM (subsurface movement)                          │
├─────────────────────────────────────────────────────────┤
│ ELSE (snails, crickets, worms, etc)                      │
│    ▶ GROUND (surface crawling)                           │
└─────────────────────────────────────────────────────────┘

POPULATION CALCULATION:
┌─────────────────────────────────────────────────────────┐
│ For each unique (rice_stage, animal_id) pair:           │
├─────────────────────────────────────────────────────────┤
│ 1. Read density_per_100m2 from CSV                       │
│ 2. Calculate desired_count:                             │
│    desired_count = ROUND(                               │
│      (density × field_area_m2 ÷ 100) × density_scale   │
│    )                                                    │
│                                                         │
│    Example:                                             │
│    density = 15 per 100m²                               │
│    field_area = 1521 m²                                 │
│    density_scale = 0.15                                 │
│    ▶ desired_count = (15 × 1521 ÷ 100) × 0.15         │
│                    = (228.15) × 0.15                    │
│                    = 34.2 ≈ 34 agents                   │
│                                                         │
│ 3. Clamp count to [1, maximum_agents_per_animal_type]  │
│    min_count = 1 (always at least one)                  │
│    max_count = 150 (perf limit)                         │
│    ▶ final_count = MAX(1, MIN(150, 34))                │
│                  = 34                                   │
└─────────────────────────────────────────────────────────┘
```

## 5. SIMULATION STATE MACHINE

```
┌────────────────────────────────────────────────────────────┐
│ GLOBAL STATE (vu2_main.gaml)                              │
├────────────────────────────────────────────────────────────┤
│ Current Cycle: 0 → ∞                                       │
│ Previous Rice Stage: "vegetative"                          │
│ Current Rice Stage: "vegetative"                           │
├────────────────────────────────────────────────────────────┤
│ STATE TRANSITIONS (Every 300 cycles):                      │
│                                                            │
│  Cycle 0-299:                                              │
│  ├─ stage_index = 0                                        │
│  └─ rice_stage = "vegetative"                              │
│     ├─ Plants: H=1.0m                                      │
│     └─ Animals: vegetative-stage CSV records               │
│                                                            │
│  Cycle 300-599:                                            │
│  ├─ stage_index = 1                                        │
│  ├─ rice_stage = "reproductive"                            │
│  ├─ Detection: "reproductive" ≠ "vegetative"              │
│  ├─ Action:                                                │
│  │  ├─ clear_rice_field() [kill 169 plants]              │
│  │  ├─ create_rice_field() [create 169 new plants]       │
│  │  ├─ clear_animals() [kill all animals]                │
│  │  └─ create_animals_for_stage("reproductive")          │
│  └─ Plants: H=1.45m + Panicles                            │
│     └─ Animals: reproductive-stage CSV records            │
│                                                            │
│  Cycle 600-899:                                            │
│  ├─ stage_index = 2                                        │
│  ├─ rice_stage = "ripening"                                │
│  ├─ Detection: "ripening" ≠ "reproductive"                │
│  ├─ Action: Same clearing & recreation                     │
│  └─ Plants: H=1.70m + Golden Grains                       │
│     └─ Animals: ripening-stage CSV records                │
│                                                            │
│  Cycle 900+:                                               │
│  ├─ Cycle 900: stage_index = 3                             │
│  ├─ rice_stage = "ripening" (no change from cycle 899)   │
│  │ (Note: "ripening" stage >= index 2, so no change)     │
│  │                                                        │
│  │ OR ALTERNATIVE: Can add cycle reset logic             │
│  │ if (stage_index > 2) then stage_index = 0             │
│  │ ▶ rice_stage = "vegetative"                            │
│  │ ▶ Cycle restarts                                       │
│  └─ [Continues indefinitely]                              │
└────────────────────────────────────────────────────────────┘
```

## 6. RENDERING PIPELINE

```
DISPLAY COMPOSITION:
┌──────────────────────────────────────────────────────────┐
│ 3D Scene at Z = 0 baseline                               │
├──────────────────────────────────────────────────────────┤
│ LAYER 1 (Bottom): Background Field                       │
│ └─ field_ground.aspect.default:                          │
│    ├─ Draw: Rectangle(39×39)                             │
│    ├─ Position: z = -0.10 (below ground)                 │
│    ├─ Color: RGB(105, 145, 75) [Light Green]            │
│    └─ Border: RGB(70, 100, 50) [Dark Green Border]      │
├──────────────────────────────────────────────────────────┤
│ LAYER 2 (Ground): Rice Plants                            │
│ └─ [rice_plant_stage].aspect.default:                    │
│    ├─ Stem: Cylinder(0.07m radius, h=1.0-1.7m)         │
│    ├─ Canopy: Sphere(0.38-0.52m radius)                 │
│    ├─ Panicles: (Reproductive & Ripening only)          │
│    │             Sphere(0.14m, golden)                   │
│    └─ At position: z = h/2 (centered)                    │
│       Grid positions: 13×13 in plane z=0                 │
├──────────────────────────────────────────────────────────┤
│ LAYER 3 (Variable): Animals (by movement_mode)           │
│ └─ Stationary animals: z = start_z (fixed)               │
│    Crawling (ground): z = 0.1-0.3m                       │
│    Flying: z = 0.5-3.0m (variable)                       │
│    Swimming: z = -0.2 to 0 (subsurface)                  │
│    └─ 3D model rendered at: location + heading           │
├──────────────────────────────────────────────────────────┤
│ LAYER 4 (Optional): Labels                               │
│ └─ IF show_rice_labels:                                  │
│    └─ "vegetative", "reproductive", "ripening"           │
│       at plant[0,0] position + 0.5m above               │
│    └─ Text size: 0.45, Color: black                      │
└──────────────────────────────────────────────────────────┘

CAMERA VIEW OPTIONS (vu2_gui_experiment.gaml):
├─ 3D Perspective: Dynamic camera angle
├─ Top-Down View: Bird's eye (shows grid layout)
└─ Custom: User-defined angle, zoom, pan
```

## 7. PERFORMANCE OPTIMIZATION

```
MEMORY & RENDERING OPTIMIZATION:
┌──────────────────────────────────────────────────────────┐
│ Density Scaling                                          │
│ ├─ CSV defines realistic ecology (100s-1000s agents)    │
│ ├─ Multiplier: 0.15 = 15% rendering                      │
│ └─ Reduces agents for real-time visualization            │
├──────────────────────────────────────────────────────────┤
│ Per-Species Cap                                          │
│ ├─ Maximum 150 agents per animal type                    │
│ └─ Prevents any single species from dominating           │
├──────────────────────────────────────────────────────────┤
│ Expected Instantiation (at 15% density):                 │
│ ├─ Total Animals ≈ 300-500 (across all species)        │
│ ├─ Total Plants: Always 169 (13×13 grid)                │
│ └─ Combined: ~500-700 total agents                       │
│    ▶ Manageable for real-time 3D rendering              │
├──────────────────────────────────────────────────────────┤
│ Recycling on Stage Change                                │
│ ├─ Every 300 cycles: clear & recreate                    │
│ └─ Prevents memory leaks from infinite spawning          │
└──────────────────────────────────────────────────────────┘
```

