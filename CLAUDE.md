# Pokémon: Lost Legends

A Pokémon Crystal ROM hack built on the pokecrystal disassembly. Gen 1/2
aesthetic; the "secret true history" of the Pokémon world — anime/manga
storylines never told in games, cut beta Pokémon, and playground myths
made real.

## Read first, every session

- `ROADMAP.md` — current state and open items. Source of truth.
- `BRANCHES.md` — resource claims. Check before using a species slot, pic
  bank, or event flag range.

Do not reconstruct project state by searching the repo. These two files are
maintained for exactly that purpose. Update them in the same commit as the
work they describe.

## Build and test

    make            # release ROM -> pokecrystal.gbc
    make devwarp    # fast-start test ROM (skips intro, testing loadout)

    python3 test/smoke_test.py pokecrystal_devwarp.gbc --list
    python3 test/smoke_test.py pokecrystal_devwarp.gbc --only core
    python3 test/smoke_test.py pokecrystal_devwarp.gbc          # full suite

A clean build proves nothing about runtime. Every bug found on device so far
assembled without a single warning. Run the tests.

**Test selection convention:**
- While iterating on a feature, run `--only <that feature>` to save time.
- **Before pushing, run the full suite with no flags.**
- CI always runs the full suite. Selection is a local speed-up, never the
  safety net — feature isolation is weaker here than it looks, since
  `intro_menu.asm` and the shared species tables are touched by almost
  everything.
- A `SKIP` is not a pass. It means the ROM's devwarp spawn didn't match what
  that group needs, so the coverage did not run.
- New feature: add a group to `GROUPS` in `test/smoke_test.py` rather than
  bolting checks onto an existing one.

## Working agreements

- **Confirm before committing or pushing.** No autonomous commits.
- Scope work to named files. Avoid repo-wide searches — this codebase is
  large and search dominates context cost.
- When you cannot verify something, say so and leave the item unchecked.
  Honest gaps have caught real bugs here. Do not paper over them.
- Reuse of a tileset means authoring new `.blk` layouts, never `INCBIN` of
  another map's block data.
- Distribute patches, not ROMs.

## Tone rules for in-game text

- Gen 2 register: short lines, plain words, implied threat.
- No winking at the camera. Myths are never confirmed by an NPC before the
  player discovers them.
- Dark content is handled with restraint — implied, never graphic.
- **No flashing, strobing, or rapid palette alternation, ever.** Safety
  requirement, not a style note.

## Pitfalls that have cost real time

- **Object coords are tile-based; block index is `(x/2, y/2)`.** Verify
  placement against the `.blk` or objects render inside walls or water.
- **`0c` is the only TILESET_FACILITY block with warp collision.** A
  `warp_event` coordinate does nothing if the block underneath isn't
  collision-tagged as a warp.
- **Catching a Transformed Pokémon always yields a Ditto** — vanilla bug in
  `engine/items/item_effects.asm`. METRONOME can reach TRANSFORM; it is not
  in `MetronomeExcepts`.
- **`hJoyDown` is a stale mirror** refreshed only by an explicit `GetJoypad`.
  Use `hJoypadDown` for live input.
- **`ReceiveItem` reads the item from `wCurItem`, not from `de`.** It routes
  to the correct pocket by the item's own attribute regardless of `hl`.
- **Pic banks 1–19 are at capacity.** New sprites go in `SECTION "Pics 20"`
  or later.
- **Species cap is 253.** Slot 252 is Gorochu; one remains. Past 253 requires
  rebuilding the index system — nobody in the Gen 2 scene has done it.
- Adding a species touches ~15 parallel tables. Add the constant first and
  let rgbasm name each table that needs an entry. Watch for placeholder rows
  sitting *after* an `assert_table_length`.
- Introducing a global label mid-script resets local (`.foo`) label scope.
- `closetext` is only valid when text is actually open.
