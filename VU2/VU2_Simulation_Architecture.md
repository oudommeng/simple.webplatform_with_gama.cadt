# VU2 Simulation Architecture & Workflow

## Overview
VU2 is a **Rice Field & Biodiversity Simulation** that models rice growth stages and associated fauna (animals) in a 3D environment using GAMA (GIS-based Agent Modeling Architecture).

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   VU2 SIMULATION ENTRY POINT                    │
│                    (vu2_main.gaml)                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
         ┌──────▼──────┐     │       ┌────▼────────┐
         │VU2_CONFIG   │     │       │VISUALIZATION│
         │             │     │       │& GUI         │
         │ - Field     │     │       │EXPERIMENT    │
         │ - CSV Data  │     │       │(Display,     │
         │ - Density   │     │       │Monitors)     │
         │ - Parameters│     │       └──────────────┘
         └──────┬──────┘     │
                │            │
         ┌──────▴──────┐ ┌───┴────────┐
         │FIELD MODEL  │ │RICE MODEL  │
         │             │ │            │
         │• Ground     │ │• 3 Stages: │
         │• Background │ │  - Vegetat.│
         │  Display    │ │  - Reproduct
         │             │ │  - Ripening│
         └─────────────┘ └────┬───────┘
                               │
                        ┌──────▼──────┐
                        │ANIMAL MODEL │
                        │             │
                        │• CSV-driven │
                        │• 20+ Species│
                        │• Movement   │
                        │• Density    │
                        │• Life stages│
                        └─────────────┘
```

---

## Component Details

### 1. **INITIALIZATION PHASE** (`vu2_main.gaml - init`)

```
init {
  ├─ do create_field_ground
  │   └─ Creates single ground agent (field background display)
  │
  ├─ do create_rice_field
  │   └─ Creates 13x13 grid of rice plants (169 plants)
  │       └─ Initial stage: "vegetative"
  │
  └─ do create_animals_for_stage("vegetative")
      └─ Loads CSV data and instantiates animals matching "vegetative" stage
}
```

### 2. **RICE STAGE PROGRESSION** (Auto-progression reflex)

```
Timeline (controlled by stage_duration_cycles = 300):
├─ Cycles 0-299: VEGETATIVE STAGE
│  ├─ Rice plants: height=1.0m, canopy=0.38m, color=dark green
│  └─ Animals: stage-specific (e.g., eggs, nymphs, larvae)
│
├─ Cycles 300-599: REPRODUCTIVE STAGE
│  ├─ Rice plants: height=1.45m, canopy=0.48m, color=medium green
│  ├─ New visual: flower panicles (0.14m spheres)
│  └─ Animals: different set from CSV (e.g., adults)
│
└─ Cycles 600+: RIPENING STAGE
   ├─ Rice plants: height=1.70m, canopy=0.52m, color=yellow-green
   ├─ Golden grain heads visible
   └─ Animals: final stage (e.g., feeding stage, predators)

On Stage Change:
  ├─ Clear all rice plants
  ├─ Create new rice grid for new stage
  ├─ Clear all animals
  └─ Create new animals from CSV for new stage
```

### 3. **FIELD CONFIGURATION** (`vu2_config.gaml`)

```
FIELD LAYOUT:
├─ Center: (50, 50)
├─ Spacing: 3.0 meters
├─ Grid: 13 columns × 13 rows = 169 plants
├─ Field Dimensions:
│  ├─ Width: 39 meters
│  ├─ Length: 39 meters
│  └─ Total Area: ~1521 m²
│
├─ Simulation World: 110×110 meter envelope
│
└─ FIELD BOUNDS:
   ├─ X range: [31, 69]
   └─ Y range: [31, 69]

CSV CONFIGURATION:
├─ Source: animal_data.csv
├─ Density Scale: 15% (reduce pop. for performance)
├─ Max Agents per Type: 150 (safety limit)
└─ Data Columns:
   ├─ [0] rice_stage (vegetative/reproductive/ripening)
   ├─ [1] stage_name
   ├─ [2] animal_id (unique identifier)
   ├─ [3] animal_name (common name)
   ├─ [4] species_name (genus/species)
   ├─ [5] life_stage (egg/nymph/adult/etc)
   ├─ [6] prefab_name (3D model name)
   ├─ [7] prefab_path (path to model asset)
   ├─ [8] density_per_100m2 (population density)
   ├─ [10] csv_x (position offset)
   ├─ [11] csv_y (position offset)
   └─ [12] csv_z (height)
```

### 4. **RICE PLANT MODEL** (3 Species)

```
VEGETATIVE RICE PLANT
├─ ID: plant_id = "R_<col>_<row>"
├─ 3D Structure:
│  ├─ Stem: cylinder (0.07m width, 1.0m height)
│  ├─ Canopy: sphere (0.38m radius)
│  └─ Color: Dark green RGB(55, 165, 65)
└─ Grid Position: discrete rows/columns

REPRODUCTIVE RICE PLANT
├─ ID: plant_id = "R_<col>_<row>"
├─ 3D Structure:
│  ├─ Stem: cylinder (0.07m width, 1.45m height)
│  ├─ Canopy: sphere (0.48m radius)
│  ├─ Panicles: sphere (0.14m) for grain heads
│  └─ Color: Medium green RGB(75, 155, 60)
└─ Grid Position: discrete rows/columns

RIPENING RICE PLANT
├─ ID: plant_id = "R_<col>_<row>"
├─ 3D Structure:
│  ├─ Stem: cylinder (0.07m width, 1.70m height)
│  ├─ Canopy: sphere (0.52m radius)
│  ├─ Grain heads: golden spheres (0.14m)
│  └─ Color: Yellow-green RGB(145, 160, 55)
└─ Grid Position: discrete rows/columns
```

### 5. **ANIMAL/BIODIVERSITY MODEL**

```
ANIMAL SPECIES (20+ types):
├─ PESTS:
│  ├─ Brown Planthopper
│  ├─ Leaf Folder / Leaffolder
│  ├─ Yellow Stem Borer
│  ├─ Golden Apple Snail
│  ├─ Rat / Rats
│  └─ Bird / Birds
│
├─ BENEFICIAL INSECTS:
│  ├─ Lynx Spider
│  ├─ Trichogramma (parasitoid wasp)
│  ├─ Wasp
│  ├─ Ladybug
│  ├─ Butterfly
│  ├─ Bee
│  └─ Cricket
│
└─ AMPHIBIANS & AQUATIC:
   ├─ Frog
   ├─ Dragonfly
   ├─ Worm
   ├─ Fish
   ├─ Duck
   └─ Snake

ANIMAL PROPERTIES:
├─ CSV Attributes:
│  ├─ Stage ID & Name
│  ├─ Animal ID, Name, Species
│  ├─ Life Stage (egg/nymph/larva/pupa/adult)
│  ├─ 3D Model (prefab_name & prefab_path)
│  └─ Density (per 100 m²)
│
├─ Behavior Attributes:
│  ├─ is_pest: boolean (true for pest species)
│  ├─ movement_mode: {ground/fly/swim/stationary}
│  ├─ movement_speed: float (0.08 default)
│  └─ movement_destination: periodic updates
│
└─ Position & Movement:
   ├─ Start: from CSV offset (local coordinates)
   ├─ Boundary: constrained to field bounds
   ├─ Random Offset: ±0.4m for natural distribution
   └─ Height: determined by movement_mode

MOVEMENT MODES:
├─ STATIONARY: Eggs, pupae (no movement)
├─ GROUND: Snails, crickets, worms (creep along surface)
├─ FLY: Insects, birds (move through air with variable height)
└─ SWIM: Fish, aquatic insects (subsurface movement)

AGENT INSTANTIATION:
├─ Count Calculation:
│  ├─ desired_count = (density × field_area_m2 ÷ 100) × density_scale
│  ├─ Clamp: [1, maximum_agents_per_animal_type]
│  └─ Example: 10/100m² × 1521m² × 0.15 = 22.8 ≈ 23 agents
│
└─ Each Animal:
   ├─ Randomly assigned CSV row from matching stage/ID
   ├─ Placed at field-relative coordinates
   ├─ Assigned movement behavior
   └─ Starts autonomous movement (if not stationary)
```

### 6. **SIMULATION CYCLE (Per Frame)**

```
GLOBAL REFLEX: progress_rice_stage
├─ Evaluate: stage_index = cycle ÷ stage_duration_cycles
├─ Update rice_stage string
├─ Detect stage change:
│  └─ If rice_stage ≠ previous_rice_stage:
│      ├─ clear_rice_field()       [kill all plants]
│      ├─ create_rice_field()      [create new stage plants]
│      ├─ clear_animals()          [kill all animals]
│      └─ create_animals_for_stage()[load new animals from CSV]
│
└─ Update previous_rice_stage

EACH ANIMAL (Per Frame):
├─ Choose destination (if timer expired and not stationary)
├─ Move toward destination at movement_speed
├─ Check if reached destination
└─ Draw 3D model from prefab

EACH RICE PLANT (Per Frame):
├─ Draw 3D structure (cylinders, spheres)
├─ Apply stage-appropriate colors
└─ (Optional) Display labels if show_rice_labels=true

GLOBAL DISPLAY:
├─ Field ground (green background)
├─ All rice plants (current stage)
├─ All animals (current stage)
├─ Camera view: 3D perspective or top-down
└─ GUI controls (stage override, density adjustment, labels)
```

---

## Data Flow

```
┌─────────────────┐
│ animal_data.csv │
└────────┬────────┘
         │
         ▼
   ┌─────────────────────┐
   │  Load CSV Matrix    │
   │  animal_data[rows]  │
   └────────┬────────────┘
            │
            ▼
   ┌─────────────────────────────────┐
   │  Init: create_animals_for_stage  │
   │  - Filter by rice_stage         │
   │  - Calculate density → count    │
   │  - Create species instances     │
   └────────┬────────────────────────┘
            │
            ▼
   ┌─────────────────────────────────┐
   │  Each Animal Agent              │
   │  ├─ Setup from CSV row          │
   │  ├─ Assign position             │
   │  ├─ Assign movement mode        │
   │  └─ Start moving (unless static)│
   └────────┬────────────────────────┘
            │
            ▼
   ┌─────────────────────────────────┐
   │  On Stage Change (every 300 cy) │
   │  ├─ Clear old animals           │
   │  ├─ Reload CSV filtered by stage│
   │  └─ Recreate animals            │
   └─────────────────────────────────┘
```

---

## Key Simulation Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| **stage_duration_cycles** | 300 | Cycles per rice stage |
| **field_area_m2** | 1521 | Total field size for density calc |
| **density_scale** | 0.15 (15%) | Population reduction factor |
| **maximum_agents_per_animal_type** | 150 | Performance/visualization limit |
| **spacing** | 3.0 | Distance between rice plants (meters) |
| **nb_cols / nb_rows** | 13 × 13 | Grid dimensions |
| **world size** | 110 × 110 | Simulation envelope |

---

## Display & Monitoring

```
DISPLAY ELEMENTS:
├─ Field Ground: green rectangle background
├─ Rice Plants: 3D cylinders + spheres (color-coded by stage)
├─ Animals: 3D models from prefabs
├─ Optional Labels:
│  ├─ show_pest_labels: highlights pest species
│  ├─ show_all_animal_labels: labels all animals
│  └─ show_rice_labels: rice stage identifier
│
└─ Monitors (Metrics):
   ├─ Current cycle
   ├─ Current rice stage
   ├─ Animal counts by species
   ├─ Plant counts by stage
   └─ Density metrics
```

---

## File Organization

```
VU2/
├── models/
│   ├── vu2_main.gaml                 [Entry point, init & reflex]
│   │
│   ├── internal/
│   │   ├── vu2_config.gaml           [Global params & CSV loading]
│   │   ├── field_model.gaml          [Field ground species]
│   │   ├── rice_model.gaml           [3 rice plant species]
│   │   ├── animal_model.gaml         [20+ animal species, behavior]
│   │   ├── vu2_gui_experiment.gaml   [Display & GUI]
│   │   └── README.md                 [Documentation]
│   │
│   └── animal_data.csv               [Population & stage data]
```

---

## Simulation Flow Summary

1. **Initialization**: Create field ground, rice grid (169 plants), and animals from CSV
2. **Progress**: Each cycle, rice stage advances based on cycle counter
3. **Stage Change**: Every 300 cycles, clear and recreate rice plants & animals for new stage
4. **Rendering**: Display 3D models, handle user input for parameters
5. **Termination**: Continue indefinitely (or until user stops)

This architecture allows easy modification of:
- Field size and plant spacing
- Rice growth visuals and progression
- Animal behaviors, densities, and life stages
- Integration with external data (CSV) and 3D assets

