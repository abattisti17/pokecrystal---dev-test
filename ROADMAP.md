# Pokémon: Lost Legends — Roadmap

Living document. Updated as work lands. The repo is the source of truth for
project state; `VERSION` holds the current version number.

---

## Current state — v0.2.0

**Pipeline is proven end to end.** Edit → commit → GitHub Actions build →
download artifact → sideload into SameBoy on iOS. No local machine required.

| thing | status |
|---|---|
| RGBDS 1.0.1 + pokecrystal build | working, byte-identical vanilla verified |
| GitHub Actions build + artifact upload | working |
| Version stamping (`vX.Y.Z-<sha>`) | working |
| Devwarp fast-start build | working; no prompts at all, spawns on the dock |
| Mew under the crate, Vermilion Port | **working, confirmed on device** (caught; v0.2.2 fixes the Ditto bug) |
| Headless smoke test (PyBoy) in CI | working, 5 checks |
| Gorochu — species slot 252 | plumbing done; placeholder sprite |

**Reference checksums**

| build | sha1 |
|---|---|
| vanilla pokecrystal | `f4cd194bdee0d04ca4eac29e09b8e4e9d818c133` |
| v0.0.2 (Oak text) | `be71af4944292d87af4ea116af36fc7998567542` |

---

## Open items

### Blocking / next up

- [x] ~~Playtest the Mew encounter.~~ Confirmed working on device.
- [x] ~~Mew failsafe.~~ Mew is now recoverable: if the battle ends in a `DRAW`
      (fled, fainted, out of Balls) the caught flag is not set, and examining
      the hollow re-triggers the encounter.
- [ ] **Playtest the failsafe.** Knock Mew out or flee, then re-examine the
      hollow — it should say "It is still here" and battle again.

### Gorochu

- [ ] **Front sprite.** Currently a recoloured Raichu placeholder. Only
      Gorochu's *back* sprite ever surfaced publicly, so the front view is an
      invention — this is an art-direction call. 56x56, 4 colours, indexed PNG.
- [ ] **Back sprite.** Rosso wants the surfaced prototype back sprite. It must
      be supplied as a file — the sandbox can only reach GitHub and package
      registries, so it cannot be downloaded here. It will also need resizing:
      the Gen 1 prototype sprite is 32x32, Gen 2 back sprites are 48x48.
- [ ] **Evolution method.** Deliberately left undefined. `GorochuEvosAttacks`
      has a learnset but no evolution trigger, and nothing evolves into it yet.
- [ ] **Obtain location.** Not placed in the world yet.

### Tooling
- [ ] **ONE species slot remains — and it is now used.** Index `$fc` was the
      only gap between Celebi (`$fb`) and EGG (`$fd`). Gorochu now occupies it.
      **Every further new Pokémon requires displacing EGG or widening the
      species index**, which touches save structures and is a much larger job.
      This needs solving before the beta roster (8+ priority species) can land.
- [ ] **Auto-create a GitHub Release on tag push.** Artifacts expire after 30
      days; releases are permanent. `git tag v0.2 && git push --tags` should
      produce a permanent download link.
- [ ] **Arbitrary-tile devwarp.** `DEVWARP_SPAWN` is limited to the fixed
      `SPAWN_*` list (Pokémon Centers). Warping into e.g. the S.S. Aqua cargo
      hold needs a different mechanism.
- [ ] **Consider Claude Code cloud sessions** for repo work, replacing the
      PAT-in-project-knowledge approach. OAuth-based, persistent, and can run
      an emulator.

### Content polish

- [ ] **In-ROM version stamp.** Filename versioning is external — rename the
      file and the link to the commit is gone. A version string on the title
      screen survives anything. Natural fit for v1.0's custom title screen.
- [ ] **Custom crate/truck sprite.** Currently `SPRITE_FAMICOM` stands in as an
      unmarked cargo crate. Works, but a purpose-drawn 16×16 overworld sprite
      would be better.
- [ ] **Devwarp starter moveset is blunt.** `DEVWARP_FIELD_MOVE` overwrites move
      slot 4 outright, destroying whatever was there. Fine for testing; don't
      read anything into the starter's moves.

---

## Branch plan

Vignette development plan and shared-resource allocation live in
[BRANCHES.md](BRANCHES.md). Claim event flags and pic banks there before
starting a branch.

## Version roadmap

- **v0.1** — Mew under the truck/crate ✅, Press B catch rate boost, one beta
  Pokémon (Kotora)
- **v0.2** — 2 new map areas, Marowak ghost quest, ASH rival with 2 battles
- **v0.3** — All 8 priority beta Pokémon with sprites + Pokédex entries
- **v0.4** — Anime arcs (Porygon, Sabrina, Bill, Lt. Surge lore)
- **v0.5** — All myth secrets (MissingNo. quest, Gorochu, Pikablu, Nidogod tablets)
- **v0.6** — Main story complete, post-game, father subplot
- **v1.0** — QA, balance, custom title screen, custom music

---

## Build reference

```bash
make            # release ROM -> pokecrystal.gbc
make devwarp    # fast-start test ROM -> pokecrystal_devwarp.gbc
```

Devwarp skips Oak's speech and the naming screen, hardcodes the player name as
DEV, grants one Pokémon, and spawns at a configurable point. Tune it in
`constants/devwarp_constants.asm`. Release builds are unaffected by the flag.

---

## Notes and gotchas

- **SameBoy keys saves to the ROM filename.** Release ROMs are versioned and
  accumulate; the devwarp ROM keeps a stable filename so it overwrites cleanly
  and never needs a save carried forward.
- **A clean build proves nothing about runtime.** Both v0.1.1 bugs assembled
  without a warning. Until the mGBA smoke test exists, on-device playtesting is
  the only real verification.
- **Event flags** for this project are allocated from the unused block at the
  end of `constants/event_flags.asm` (46 remaining).
- **Introducing a global label inside a script resets local (`.foo`) label
  scope.** Splitting `VermilionPortTruckScript` broke every `.End` below the new
  label. Use fully-qualified script names when a script has multiple entry points.
- **`closetext` is only valid when text is actually open.** Branches taken after
  a `closetext`, or after `startbattle`, must jump to a plain `end`.
- **Adding a species means ~15 parallel tables**, each with its own
  `assert_table_length`. The fastest method is to add the constant first and
  let rgbasm name each table that needs an entry. Watch where the assert sits:
  several tables have placeholder rows *after* the `NUM_POKEMON` assert that
  must be replaced rather than added to.
- **Pic banks 1–19 are at capacity in vanilla pokecrystal.** New species pics
  must go in `SECTION "Pics 20"` or later, which are empty.
- **Catching a Transformed Pokemon always yields a Ditto.** This is a *vanilla*
  Crystal bug, flagged in `engine/items/item_effects.asm` and documented in
  `docs/bugs_and_glitches.md`. The catch code assumes only Ditto can ever be
  transformed, since Ditto is the only Pokemon that learns Transform in normal
  play. Mew is the exception and is unobtainable in vanilla, so it never came
  up. **Any future catchable Pokemon with Transform will hit this**, and
  METRONOME can reach TRANSFORM because it is not in `MetronomeExcepts`.
  Fixed here by removing both moves from Mew rather than patching the shared
  catch path, which would affect every capture in the game.
- **Object placement must be checked against the `.blk` map.** Coordinates are
  tile-based; block `(x/2, y/2)` indexes into the `.blk`. Vermilion Port's
  walkable deck is block row 5 (tile rows 10–11). Placing an object on a
  decorative pier-face block puts it visibly out over the water.
- Upstream pokecrystal has moved to RGBDS 1.0.3; the workflow pins 1.0.1, which
  still builds correctly.
