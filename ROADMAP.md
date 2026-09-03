# Pokémon: Lost Legends — Roadmap

Living document. Updated as work lands. The repo is the source of truth for
project state; `VERSION` holds the current version number.

---

## Current state — v0.1.2

**Pipeline is proven end to end.** Edit → commit → GitHub Actions build →
download artifact → sideload into SameBoy on iOS. No local machine required.

| thing | status |
|---|---|
| RGBDS 1.0.1 + pokecrystal build | working, byte-identical vanilla verified |
| GitHub Actions build + artifact upload | working |
| Version stamping (`vX.Y.Z-<sha>`) | working |
| Devwarp fast-start build | working; spawns on the dock with Strength + badge |
| Mew under the crate, Vermilion Port | placed on walkable deck, needs playtest |

**Reference checksums**

| build | sha1 |
|---|---|
| vanilla pokecrystal | `f4cd194bdee0d04ca4eac29e09b8e4e9d818c133` |
| v0.0.2 (Oak text) | `be71af4944292d87af4ea116af36fc7998567542` |

---

## Open items

### Blocking / next up

- [ ] **Playtest the Mew encounter.** Devwarp grants the badge and Strength,
      so it should be reachable within seconds of booting.
- [ ] **Mew failsafe.** Currently a one-shot: no handling for fleeing, fainting,
      or running out of Poké Balls. Sudowoodo's script (`maps/Route36.asm`) is
      the model — it handles `DRAW` and re-encounters. Decide whether Mew should
      be permanently missable or recoverable.

### Tooling

- [ ] **mGBA smoke test in Actions.** The single highest-value addition.
      Neither Claude nor Claude Code can catch runtime bugs from a clean
      assembly — both v0.1.1 bugs compiled fine. A headless mGBA boot with
      scripted inputs and a screenshot artifact would catch this whole class
      of bug automatically.
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
- **Object placement must be checked against the `.blk` map.** Coordinates are
  tile-based; block `(x/2, y/2)` indexes into the `.blk`. Vermilion Port's
  walkable deck is block row 5 (tile rows 10–11). Placing an object on a
  decorative pier-face block puts it visibly out over the water.
- Upstream pokecrystal has moved to RGBDS 1.0.3; the workflow pins 1.0.1, which
  still builds correctly.
