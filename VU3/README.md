# VU3 — Rice Ecosystem Interactions

VU3 extends VU2 instead of copying it. Changes to VU2 field creation, rice
stages, animal data, movement, GUI, and Unity mappings flow into VU3 when the
model is reloaded.

## What VU3 adds

Every cycle uses this fixed order:

1. Remove the previous cycle's active impact indicators.
2. Let nearby supported beneficials control at most one pest each.
3. Remove controlled pests immediately.
4. Apply impact only from surviving pests close to rice.
5. Spread a smaller impact to neighboring rice plants.

There is no lingering impact duration. When a beneficial controls a pest, that
pest contributes no impact in the same cycle. If other pests still attack the
same plant, their impact remains.

## Brown Planthopper egg laying

VU3 does not create Brown Planthopper eggs from the free-floating CSV spawn
points. Instead:

1. An adult must enter the configured contact radius of a rice plant.
2. The egg-laying probability is checked.
3. A successful adult creates one stationary egg agent on that rice plant.
4. Per-adult cooldown and limits, plus a per-rice limit, prevent unlimited
   spawning.
5. Eggs remain available as life-stage-specific beneficial targets, but eggs
   do not directly damage rice.

Egg hatching and maturation are not implemented yet. VU2 keeps its original
seeded-egg behavior because the replacement is enabled only by VU3.

## Pest impact types

| Pest | Active rice impact |
| --- | --- |
| Leaf Folder | `folds_leaves` |
| Brown Planthopper | `sucks_sap` |
| Yellow Stem Borer | `bores_stem` |
| Golden Apple Snail | `eats_seedlings` |
| Rat and Bird | `eats_grains` |

The nearest rice plant receives the primary impact. Rice within the configured
neighbor radius receives a reduced impact.

## Beneficial rules

Rules follow the supplied vegetative, reproductive, and ripening diagrams:

### Vegetative stage

Only Brown Planthopper, Green Leaf Folder, and Golden Apple Snail actively
damage rice in this stage.

- Trichogramma attacks Green Leaf Folder eggs.
- Wasp parasitizes Green Leaf Folder larvae.
- Lynx Spider, Frog, and Dragonfly eat Brown Planthopper nymphs and Green Leaf
  Folder larvae.
- Duck and Rat eat Golden Apple Snail.

Rat is intentionally treated as a beneficial snail controller by VU3 during
the vegetative stage, even though VU2's legacy data classifies it as a pest.
Yellow Stem Borer and Bird can still appear because they come from VU2 data,
but they have no vegetative VU3 impact or control role.

### Reproductive stage

- Only Brown Planthopper, Green Leaf Folder, and Yellow Stem Borer actively
  damage rice.
- Trichogramma attacks Green Leaf Folder eggs and Yellow Stem Borer eggs.
- Wasp parasitizes Green Leaf Folder larvae and Yellow Stem Borer larvae.
- Lynx Spider, Frog, and Dragonfly eat Brown Planthopper nymphs, Green Leaf
  Folder larvae, and Yellow Stem Borer larvae.
- Weaver Ant eats Yellow Stem Borer larvae.

Ladybug, Duck, Snake, Rat, Bird, and other inherited VU2 animals can remain
visible, but they have no VU3 reproductive interaction role.

### Ripening stage

- Only Brown Planthopper, Rat, and Bird actively damage rice.
- Brown Planthopper sucks sap; Rat and Bird eat grains.
- Lynx Spider, Frog, and Dragonfly eat Brown Planthopper nymphs.
- Snake eats Rat.

Bird has no controller in the supplied table. Raptors are not created because
there is no Raptor species, population record, or Unity mapping in VU2.

## Run

- GAMA GUI: open `models/vu3_main.gaml` and run experiment `vu3`.
- Unity/VR: open `models/vu3_main-VR.gaml` and run experiment `vu3_vr`.

Interaction radii, neighbor strength, beneficial success probability, and
impact labels are configurable from the VU3 experiment.
