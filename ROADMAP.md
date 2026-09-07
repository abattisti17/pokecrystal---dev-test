# Pokémon: Lost Legends — Roadmap

Living document. Describes **now**, not history. Completed work is deleted, not
struck through — git has the history.

**Read order for a new session:** `DECISIONS.md` → this file → `BRANCHES.md` →
`CLAUDE.md`. `RESEARCH.md` for background on why myths were built as they were.

---

## Current state — v0.5.3, on `master`

The whole pipeline runs from a phone: edit → push → GitHub Actions builds →
download artifact → sideload into SameBoy on iOS. No local machine.

| Feature | Status |
|---|---|
| Mew under the truck, Vermilion Port | working, caught on device. DRAW failsafe. Moveset has no Transform |
| Gorochu, species 252 | in the game, loads clean. **Placeholder sprite**, no evolution method, not obtainable |
| The Transfer Network — Porygon | three hand-authored rooms, catchable Porygon with DRAW failsafe |
| Press B catch bonus | built; rewards *holding* B. Runtime effect not measured on device |
| Devwarp fast-start | no prompts. Party of 4, testing loadout, spawns at Vermilion Port |
| Headless smoke test (PyBoy) | grouped by feature, `--only` selection, runs full suite in CI |
| Versioned ROM artifacts | `LostLegends-vX.Y.Z-<sha>.gbc` |

**The truck currently has no sprite.** Three attempts at porting the Gen 1 truck
tileset all rendered white and were reverted. See "Open items."

---

## Open items

### Blocking

- [ ] **Truck tileset rendering.** The Gen 1 truck is 8 tiles from pokered's
      `ship_port` block `$03`. `TILESET_PORT` has only 5 free bank-0 slots
      across its three maps; a Vermilion-only tileset frees 22 and is the right
      approach. Prime suspect for the white render: `data/tilesets.asm` starts
      with a dummy `Tileset0` at index 0, so table position must equal constant
      value + 1 — the previous attempt appended to the table while numbering
      the constant mid-range, so the map likely loaded a different tileset.
- [ ] **Species cap decision.** One slot left. MissingNo., Venustoise and every
      beta Pokémon each need one. See DECISIONS.md for the approved removal
      list. Nothing in Pillar 2 can proceed until this is settled.

### Gorochu

- [ ] Front sprite — an invention; only the back sprite ever leaked. 56x56,
      4 colours, indexed PNG. Art-direction call.
- [ ] Back sprite — Rosso wants the surfaced prototype sprite. Must be supplied
      as a file; the sandbox can only reach GitHub and package registries. Will
      need redrawing: the Gen 1 prototype is 32x32, Gen 2 backs are 48x48.
- [ ] Evolution method — deliberately undefined. Learnset exists, no trigger.
- [ ] Not placed in the world.

### Tooling

- [ ] **Reachability check in CI.** Three truck placements were shipped to an
      unreachable spot because analysis modelled tile collision only.
      Reachability needs collision + NPC positions + `coord_event`s. Worth
      automating so it can't recur.
- [ ] **GitHub Release on tag push.** Artifacts expire after 30 days; releases
      are permanent.
- [ ] **In-ROM version stamp.** Filename versioning breaks if a file is
      renamed. Natural fit for v1.0's custom title screen.

### Content, next up

- [ ] **MissingNo.** — catchable, hard-coded, simulated corruption. Costs the
      last species slot unless removals happen first.
- [ ] **Venustoise**, **Giant Tentacruel**, **Ho-Oh in the sky** — wanted, not
      started. See DECISIONS.md.

---

## Build reference

```bash
make            # release ROM -> pokecrystal.gbc
make devwarp    # fast-start test ROM
python3 test/smoke_test.py pokecrystal_devwarp.gbc --list
python3 test/smoke_test.py pokecrystal_devwarp.gbc            # full suite
```

Devwarp skips all intro prompts, grants a testing loadout, and spawns at
Vermilion Port. Tune in `constants/devwarp_constants.asm`.

A `SKIP` in the test output is **not** a pass — it means the ROM's spawn
didn't match what that group needs, so the coverage didn't run.

---

## Reference checksums

| build | sha1 |
|---|---|
| vanilla pokecrystal | `f4cd194bdee0d04ca4eac29e09b8e4e9d818c133` |

---

## Notes and gotchas

Engine-level pitfalls live in `CLAUDE.md`, which Claude Code reads every
session. Project-level notes only here:

- **A clean build proves nothing about runtime.** Every bug found on device so
  far assembled without a warning. Playtest, or run the smoke test.
- **Playtest reports outrank analysis.** The unreachable truck was caught by
  playing in a minute after a flood fill said it was fine.
- **SameBoy keys saves to the ROM filename.** Release ROMs are versioned and
  accumulate; the devwarp ROM keeps a stable filename so it overwrites cleanly.
- **Distribute patches, not ROMs.**
