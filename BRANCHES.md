# Lost Legends — Branch Plan & Resource Allocation

Vignettes are built as branches off `master`. Each should be playable standalone
(via a devwarp entry point) but merge cleanly into the trunk.

**The trunk owns all shared tables.** Anything in the "contested" list below must
be claimed here *before* a branch touches it, or merges become archaeology.

---

## Contested resources

These are global. Two branches editing the same one will conflict.

| Resource | Total | Claimed | Free |
|---|---|---|---|
| Species slots | 253 max | 252 (Gorochu) | **1** |
| Pic banks | `Pics 20`–`Pics 24` | 20 (Gorochu) | 21, 22, 23, 24 |
| Map groups | append-only, `NUM_MAP_GROUPS` | 27, `TRANSFER_NETWORK` (Porygon) | 28+ |
| Spawn points | fixed `SPAWN_*` list | `SPAWN_TRANSFER_NETWORK_ENTRY` added | more can be appended |
| `DEVWARP_SPAWN` (current value) | one at a time | Transfer Network's entry | next branch: repoint or coordinate |
| Save structure | — | — | changes break old saves |

Map groups are append-only and safe to add (see `constants/map_constants.asm`'s
`newgroup`/`endgroup` pattern) — claim a name here so two branches don't both
grab "the next number." `DEVWARP_SPAWN` is a single global default in
`constants/devwarp_constants.asm`; only one branch's content is reachable via
`make devwarp` at a time. Whoever builds the next branch should either repoint
it at their own entry (bumping trunk's default back to `SPAWN_VERMILION` on
merge, per the working agreements) or coordinate here first.

Free ROM space: ~401 KB. Free event flags: ~662. Neither is a near-term concern.

## Event flag allocation

`constants/event_flags.asm` has four unused blocks. One block per branch avoids
renumbering churn on merge.

| Block | Size | Assigned to |
|---|---|---|
| after `EVENT_BATTLE_TOWER_OPEN_CIVILIANS` | 44 remaining | trunk / Mew (2 used) |
| "next 339 events" block | 339 | **A Mother's Promise**, then Maiden's Real Name |
| "next 167 events" block | 167 | **Data Ghost** (MissingNo.) |
| "next 116 events" block | 116 (110 free) | **The Transfer Network** (Porygon, 6 used) |

Unassigned branches: claim a sub-range here before starting.

---

## Branches

Ordered by recommended build order — cheapest and least contested first.

### 1. A Mother's Promise — Marowak
- **Location:** Pokémon Tower, new floors
- **Species:** none
- **Conflict risk:** low. Entirely new maps.
- **Why first:** best tone demo in the project. Self-contained, no shared
  resources, and the Marowak ghost is the most recognisable piece of Gen 1
  darkness. Bible gives her a name and Cubone's — that reveal is the payoff.

### 2. The Maiden's Real Name
- **Location:** Ecruteak City
- **Species:** none
- **Conflict risk:** low
- **Note:** shortest quest on the list. Good second branch to prove the
  merge process works while the first is still fresh.

### 3. Data Ghost — MissingNo.
- **Location:** Cinnabar Island Lab
- **Species:** **none** — MissingNo. occupies the *empty* index slots by
  definition, which is the myth's actual mechanism. Structurally free.
- **Conflict risk:** medium. Cinnabar map edits.
- **Note:** best cost-to-payoff ratio. Needs a decision on which of the real
  glitch effects to reproduce (sprite corruption, Hall of Fame damage) versus
  merely reference.

### 4. The Transfer Network — Porygon — ✅ done (v0.4.0)
- **Location:** new map group `TRANSFER_NETWORK` (27), entered from Bill's
  House (`maps/BillsHouse.asm`) — not Goldenrod Radio Tower as originally
  scoped here. Reframed around the PC transfer system (Bill's own domain in
  Gen 2) rather than a broadcast; same source myth (anime EP038), different
  in-world mechanism. Three rooms: `TransferNetworkEntry`,
  `TransferNetworkBlockade`, `TransferNetworkDeepNode` — all reuse existing
  map layouts and tilesets (`RuinsOfAlphResearchCenter`'s and
  `DragonShrine`'s block data, aliased in `data/maps/blocks.asm`), no new
  tile art.
- **Species:** none (Porygon exists, species 137) — removed from
  `SometimesFleeMons` in `data/wild/flee_mons.asm` so the quest reward can't
  just run off; see the comment there.
- **Event flags:** 6 used from the "next 116" block (`EVENT_TRANSFER_NETWORK_*`,
  `EVENT_FOUGHT_PORYGON`), 110 left in that block.
- **Conflict risk:** low. Touches `maps/BillsHouse.asm` (added Bill as an
  NPC there — his grandfather's dialogue already establishes Bill is
  reachable by PC from Johto, so this doesn't contradict anything) and the
  shared per-map-group tables (`data/maps/maps.asm`, `attributes.asm`,
  `blocks.asm`, `scripts.asm`, `roofs.asm`, `outdoor_sprites.asm`,
  `sgb_roof_pal_inds.asm`, `roofs.pal`) for the new group — all append-only.
- **DEVWARP_SPAWN** currently points here (`SPAWN_TRANSFER_NETWORK_ENTRY`).
  Repoint to `SPAWN_VERMILION` (or the next branch's own entry) before/at
  merge — see the resource table above.
- **Gotcha for future branches reusing a map's block data:** the tile
  *layout* being walkable isn't enough for a `warp_event` (walk-onto-tile
  warp) to fire — the underlying tile also needs warp-type collision
  (`CheckWarpCollision` in `engine/overworld/tile_events.asm`), which only
  exists where the *source* map had a real door. A reused layout only has
  warp-collision at that original door. Anywhere else you want to leave
  from, use an `OBJECTTYPE_SCRIPT` object with a script-level `warp <map>,
  x, y` command instead (no collision-type requirement). This cost real
  time to find — don't rediscover it.

### 5. The Soldier's War — Lt. Surge
- **Location:** Cerulean Cave entrance, veteran NPCs across the map
- **Species:** none
- **Conflict risk:** low, but *diffuse* — touches NPCs in many existing maps,
  so it collides with anything else editing those towns. Best merged early or
  kept to new NPCs only.

### 6. Sabrina's Origin
- **Location:** Saffron psychic underground
- **Species:** none
- **Conflict risk:** medium — new underground area beneath an existing city.

### 7. Bill's Other Experiment
- **Location:** Vermilion Sea Cottage
- **Species:** none
- **Conflict risk:** **high** — edits Vermilion, where the Mew crate already
  lives. Rebase onto trunk before starting.

### 8. The Fourth Form — Gorochu
- **Location:** Safari Zone deep zone
- **Species:** already spent (252)
- **Conflict risk:** medium
- **Blocked on:** front sprite art direction, back sprite file, evolution method.

### 9. The Remembered Ones — Pokégods
- **Location:** Lavender Town
- **Species:** **5 needed, 1 available — BLOCKED**
- **Decision required:** cut to a single encounter, implement as species
  variants (reuse an existing ID with a flag bit selecting stats/sprite/name),
  or reclaim slots by removing existing species.

---

## Reclaimable species

Species with no evolution family, no trainer use, and no script or event
references. Cheapest to replace; *not* a recommendation.

| Species | Wild spawns |
|---|---|
| Misdreavus | 3 |
| Gligar | 3 |
| Heracross | 7 |
| Mantine | 1 |
| Skarmory | 4 |
| Stantler | 2 |
| Smeargle | 6 |

(Mewtwo also qualifies mechanically — unobtainable in vanilla Crystal — but is
story-critical here.)

---

## Working agreements

- Branch from `master`, never from another vignette branch.
- Claim event flags and pic banks in this file, in a commit, before using them.
- Every branch gets a devwarp entry point so playtesters reach the content in
  seconds. Set `DEVWARP_SPAWN` and party contents in `constants/devwarp_constants.asm`.
- Add at least one smoke test check per branch — typically "the quest's
  completion flag can be set" or "the new species/item exists".
- Distribute **patches**, not ROMs.
- Rebase onto `master` before opening a merge, so conflicts surface on the
  branch rather than in the trunk.
