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
| Spawn points | fixed `SPAWN_*` list | devwarp override | — |
| Save structure | — | — | changes break old saves |

Free ROM space: ~401 KB. Free event flags: ~668. Neither is a near-term concern.

## Event flag allocation

`constants/event_flags.asm` has four unused blocks. One block per branch avoids
renumbering churn on merge.

| Block | Size | Assigned to |
|---|---|---|
| after `EVENT_BATTLE_TOWER_OPEN_CIVILIANS` | 44 remaining | trunk / Mew (2 used) |
| "next 339 events" block | 339 | **A Mother's Promise**, then Maiden's Real Name |
| "next 167 events" block | 167 | **Data Ghost** (MissingNo.) |
| "next 116 events" block | 116 | **The Last Broadcast** (Porygon) |

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

### 4. The Last Broadcast — Porygon
- **Location:** Goldenrod Radio Tower basement
- **Species:** none (Porygon exists)
- **Conflict risk:** low
- **Note:** handle the seizure origin with care. The in-game event is a
  broadcast causing Pokémon illness — no flashing effects.

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
