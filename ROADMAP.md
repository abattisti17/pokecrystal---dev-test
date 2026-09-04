# Pokémon: Lost Legends — Roadmap

Living document. Updated as work lands. The repo is the source of truth for
project state; `VERSION` holds the current version number.

---

## Current state — v0.4.0

**Pipeline is proven end to end.** Edit → commit → GitHub Actions build →
download artifact → sideload into SameBoy on iOS. No local machine required.

| thing | status |
|---|---|
| RGBDS 1.0.1 + pokecrystal build | working, byte-identical vanilla verified |
| GitHub Actions build + artifact upload | working |
| Version stamping (`vX.Y.Z-<sha>`) | working |
| Devwarp fast-start build | working; **currently spawns in the Transfer Network's Entry room**, not Vermilion Port — see BRANCHES.md and Open items below |
| Mew under the crate, Vermilion Port | working, confirmed on device (v0.2.2 fixes the Ditto bug); **not reachable from devwarp on this branch** while `DEVWARP_SPAWN` points at the Transfer Network |
| The Transfer Network — Porygon vignette | working in headless testing — three rooms, item pickups, DRAW-failsafe Porygon encounter; **map layout is placeholder, see Open items** |
| Headless smoke test (PyBoy) in CI | working, 9 checks; walks the Transfer Network end to end. Mew/Vermilion coverage is not currently exercised by this branch's default devwarp build — see Open items
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

### The Transfer Network — Porygon (v0.4.0)

- [x] ~~Three rooms, reused tilesets, no new sprites.~~ `TransferNetworkEntry`,
      `TransferNetworkBlockade`, and `TransferNetworkDeepNode` reuse
      `RuinsOfAlphResearchCenter`'s and `DragonShrine`'s block data (aliased,
      not duplicated) and `TILESET_FACILITY`/`TILESET_LAB`. No flashing
      effects anywhere — static palettes only, per the hard safety
      requirement in the brief.
- [x] ~~Bill gates entry from Bill's House.~~ Added as a new NPC there
      (`BILLSHOUSE_BILL`); his grandfather's existing dialogue already
      explains Bill is reachable by PC from Johto, so this doesn't contradict
      anything already in the map.
- [x] ~~Porygon catchable with a DRAW failsafe.~~ Mirrors
      `VermilionPortMewBattleScript` exactly: `setevent EVENT_FOUGHT_PORYGON`
      before `reloadmapafterbattle`, both last in each branch. Confirmed in
      headless (PyBoy) testing: the battle triggers with the correct species
      (137) at the correct map coordinates, and fleeing (DRAW) returns to the
      overworld without setting the flag. Porygon was also removed from
      `SometimesFleeMons` (see `data/wild/flee_mons.asm`) so the encounter
      itself can't just run off mid-battle.
- [x] ~~Devwarp entry point.~~ `DEVWARP_SPAWN` is now a real constant (it
      wasn't before — this closes part of the old "arbitrary-tile devwarp"
      tooling gap below) and currently points at
      `SPAWN_TRANSFER_NETWORK_ENTRY`. **This means devwarp no longer reaches
      Vermilion Port / the Mew crate** until something repoints it back — see
      BRANCHES.md's resource table.
- [x] ~~Smoke test walks the network end to end.~~ 9 checks, PASSED
      reproducibly across 3 consecutive runs: spawn location, party contents,
      reaching Blockade, reaching Deep Node, and the Porygon battle
      triggering with the right species. This is the same rigor the existing
      Mew check had — battle *entry*, not a completed catch (see below).
- [ ] **Not independently re-verified after the DRAW failsafe fires: does
      re-examining the source correctly show "it's gone quiet" (post-catch)
      vs. re-battling (post-flee)?** I confirmed fleeing returns to the
      overworld cleanly and does not set `EVENT_FOUGHT_PORYGON`, and the
      underlying script is byte-for-byte the same shape as Mew's
      already-proven pattern — but my own attempt to script a clean
      re-examine round-trip got tangled in battle-menu RNG (a random AI
      move burned a turn differently each run) before I could screenshot it
      directly. Confidence is high given the code match to Mew, but this
      wants an actual on-device or manual-emulator look before calling it
      fully proven.
- [ ] **Only the Ultra Ball pickup was individually confirmed** (picked up,
      correctly went to the Ball Pocket — Poké Balls and TMs use a different
      inventory list than regular Items, which briefly looked like a bug
      until I checked the right pocket). The Revive, Ether, and TM Swift
      itemballs use the identical `OBJECTTYPE_ITEMBALL` pattern at
      similarly-confirmed-walkable coordinates, so they should behave the
      same, but weren't each individually walked up to and collected in
      testing.
- [ ] **The "back doorway" objects** (return to the previous room from
      Blockade and from Deep Node) use the same script-`warp` pattern as the
      "go deeper" doorways, which *is* proven working — but the return
      objects themselves weren't individually walked up to and triggered in
      testing, only reasoned about by symmetry.
- [ ] **On reused layouts, only `warp_event` (walk-onto-tile) needs real
      warp-type tile collision — the destination of a script-level `warp`
      command does not, and neither does object placement.** This was a real
      bug hunt (a `warp_event` placed on ordinary floor silently never
      fires — see `CheckWarpCollision` in
      `engine/overworld/tile_events.asm`), now worked around by using
      `OBJECTTYPE_SCRIPT` doorway objects for every in-network transition.
      Documented in BRANCHES.md for the next branch reusing a map layout.
- [ ] **Bill's post-quest dialogue** (`BillClearedText`, shown once
      `EVENT_FOUGHT_PORYGON` is set) was not exercised in testing — it's a
      straightforward `checkevent` branch matching the same pattern as
      everything else in his script, but wasn't specifically walked through.

### Transfer Network vignette (pre-merge)

- [ ] **Map layout is placeholder, not new content.** `TransferNetworkEntry`
      and `TransferNetworkBlockade` both `INCBIN` the Ruins of Alph Research
      Center's actual `.blk` file, unmodified. `TransferNetworkDeepNode` does
      the same with Dragon Shrine. This is not "reusing the tileset" — it is
      the same room, relabeled. Needs real hand-laid `.blk` layouts using the
      tileset as the reusable asset, not the map. A tile-by-tile layout spec
      is the next step, to be written up separately.
- [ ] **Restore Mew coverage before merging to master.** `DEVWARP_SPAWN`
      points at the Transfer Network on this branch, and the smoke test's
      default checks were swapped from Vermilion/Mew to the network rather
      than kept alongside it. Per BRANCHES.md's own stated convention, this
      is expected mid-branch but must not land on master this way, or every
      future branch that reuses devwarp for its own testing will keep
      silently dropping Mew coverage. Fix needs a real decision, not a revert:
      either two devwarp targets (`make devwarp` for trunk content, a second
      target per vignette), or restore `DEVWARP_SPAWN` to `SPAWN_VERMILION`
      here and reach the network the normal way (Bill's House, Route 25) for
      this branch's own testing.

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
- [x] ~~`DEVWARP_SPAWN` is now a real, tunable constant~~ (was previously a
      value hardcoded straight into `engine/menus/intro_menu.asm`). Still
      limited to the fixed `SPAWN_*` list (Pokémon Centers and now the
      Transfer Network's entry) — warping into an arbitrary tile like the
      S.S. Aqua cargo hold still needs a different mechanism, and appending
      a new `SPAWN_*` entry per vignette branch is the expected pattern for
      now (see BRANCHES.md).
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
- **v0.4** — Anime arcs (~~Porygon~~ landed as "The Transfer Network," see Open
  items — Sabrina, Bill's Other Experiment, Lt. Surge lore still open)
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
