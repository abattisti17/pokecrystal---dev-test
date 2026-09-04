# Pokémon: Lost Legends — Roadmap

Living document. Updated as work lands. The repo is the source of truth for
project state; `VERSION` holds the current version number.

---

## Current state — v0.3.0

**Pipeline is proven end to end.** Edit → commit → GitHub Actions build →
download artifact → sideload into SameBoy on iOS. No local machine required.

| thing | status |
|---|---|
| RGBDS 1.0.1 + pokecrystal build | working, byte-identical vanilla verified |
| GitHub Actions build + artifact upload | working |
| Version stamping (`vX.Y.Z-<sha>`) | working |
| Devwarp fast-start build | working; no prompts at all, spawns on the dock |
| Mew under the crate, Vermilion Port | **working, confirmed on device** (caught; v0.2.2 fixes the Ditto bug) |
| Headless smoke test (PyBoy) in CI | working, 6 checks (adds a wild-battle-entry check) |
| Gorochu — species slot 252 | plumbing done; placeholder sprite |
| "Press B to catch" myth | code lands, builds clean; joypad-mirror bug found and fixed; net catch-rate effect still wants on-device confirmation — see note below |

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
- [x] ~~Playtest the failsafe.~~ Headless (PyBoy) playtest found a real bug:
      `VermilionPortMewBattleScript` called `reloadmapafterbattle` *before*
      the `ifequal DRAW` check and `setevent EVENT_FOUGHT_TRUCK_MEW` —
      `reloadmapafterbattle` internally stops script execution and reloads
      the map, so those two lines never ran, on *any* battle outcome. Fixed
      by matching vanilla's own pattern (see `Route36.asm`'s Sudowoodo
      script): resolve the result and set the event first, call
      `reloadmapafterbattle` last, in each branch.
- [ ] **Hollow goes dead after the Mew battle.** Separate from the above: in
      headless testing, once you've fought Mew and returned to the map, the
      crate/hollow object stops responding to `A` entirely — no text, no
      re-battle, nothing — even though other NPCs on the same map (tested:
      the Super Nerd) remain interactive right after the same battle. Not
      yet root-caused; needs on-device confirmation since PyBoy's object/
      script emulation could conceivably differ from real hardware here.
- [ ] **"Press B to catch" myth (v0.1 target, landed in v0.3.0).** Implemented
      per spec in `engine/items/item_effects.asm` (`.skip_hp_calc`, right
      before the catch roll) and `constants/battle_constants.asm`
      (`LOST_LEGENDS_CATCH_BUTTON` = `PAD_B`, `LOST_LEGENDS_B_CATCH_BONUS` =
      13, both tunable there). Master Ball and the tutorial battle still
      bypass it via `.catch_without_fail`, confirmed unchanged. `make` and
      `make devwarp` both build clean, and the inserted bytes were verified
      by hand against the built ROM (correct opcodes at `PokeBallEffect`,
      correctly capped at `$ff` on carry).

      **Correction to an earlier note in this file:** `wFinalCatchRate`
      (`$D1EA`) and `wThrownBallWobbleCount` (`$D1EB`) are *adjacent* bytes
      (see `ram/wram.asm`), not a shared address. `wFinalCatchRate` is not
      overwritten by the wobble animation. The earlier claim here was wrong.

      **Bug found and fixed: the code was reading the wrong joypad mirror.**
      It read `hJoyDown` (`$FFA8`), which is only refreshed by an explicit
      `GetJoypad` call — and nothing calls `GetJoypad` between `PrintText`
      and the catch roll, so it was reading a stale value (confirmed: it
      sits frozen at its pre-throw state through the whole "used the POKÉ
      BALL!" sequence). Changed to `hJoypadDown` (`$FFA4`), which
      `UpdateJoypad` writes unconditionally every VBlank — confirmed via
      direct CPU-register inspection (PyBoy `hook_register`) that it tracks
      real held-button state continuously, frame to frame, right up to the
      roll.

      **Real remaining risk, confirmed in testing: pressing B at the same
      instant as confirming "USE" cancels back to the bag's item list**,
      instead of throwing the ball. B doubles as the menu's cancel button,
      and a *fresh* press-edge on it right at that confirmation reads as
      "go back," not "held during the throw." Holding B continuously from
      *before* opening the bag (so it's not a fresh edge at the confirm
      moment) does not cancel — the throw proceeds normally. Net effect:
      the myth works for a player who's already holding B as they open the
      bag, not one who presses B and A at the same instant.

      I was not able to get a fully clean, repeatable end-to-end
      measurement of the catch-rate delta itself in headless testing —
      `wFinalCatchRate` readings were inconsistent across otherwise-identical
      runs once B was in the mix (I suspect my own test harness has timing
      sensitivities I didn't fully pin down, not the game logic), so I'm not
      marking this fully done. The joypad-mirror bug is real and fixed; the
      cancel risk is real and documented; the net catch-rate effect still
      wants on-device confirmation.

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

### Devwarp

- [x] Testing loadout: 999,999 money, 99x Ultra Ball, 99x Potion, Bicycle.
      Granted on every devwarp new game. Tune in `constants/devwarp_constants.asm`.

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

- **v0.1** — Mew under the truck/crate ✅, ~~Press B catch rate boost~~ (landed
  in v0.3.0 instead, see Open items), one beta Pokémon (Kotora)
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
- **`hJoyDown` ($FFA8) only updates when something explicitly calls
  `GetJoypad`.** It is not a live per-frame mirror — `hJoypadDown` ($FFA4)
  is, written unconditionally every VBlank by `UpdateJoypad`. Reading
  `hJoyDown` from code that runs between `PrintText` calls (no
  `GetJoypad` in between) reads a stale value. Bit us on the "Press B to
  catch" myth; see that entry above. Prefer `hJoypadDown` for anything that
  needs the actual current input outside the normal overworld/menu input
  loop.
- **The catch roll fires the instant "USE" is confirmed**, before the "used
  the POKÉ BALL!" text or the throw animation play — not after them.
  A fresh press of B at that exact confirm doubles as the bag menu's cancel
  button, backing out instead of throwing. B already held from before
  opening the bag does not have this problem.
