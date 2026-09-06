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

- **Reachability depends on THREE things, not one: tile collision, NPC
  positions, AND `coord_event`s.** Vermilion Port's `coord_event 7, 11` is the
  clearest case: that tile is the only link between the north deck and the
  southern basin, and stepping on it force-boards you onto the ship. The
  southern half of that map is therefore permanently unreachable on foot or by
  Surf, no matter what the collision data says.
- **NPCs block their tile.** A flood
  fill over `*_collision.asm` alone will report areas reachable that a player
  cannot actually get to. The Vermilion Port gangway sailor at (7,17) plugs the
  only route south single-handedly.
- **Key items are stored as (id, quantity) pairs**, so ids are every *other*
  byte after `wNumKeyItems`.
- **Object coords are tile-based; block index is `(x/2, y/2)`.** Verify
  placement against the `.blk` or objects render inside walls or water.
- **`0c` is the only TILESET_FACILITY block with warp collision.** A
  `warp_event` coordinate does nothing if the block underneath isn't
  collision-tagged as a warp. It's also *directional*
  (`CheckDirectionalWarp` in `engine/overworld/tile_events.asm`): standing
  on the tile isn't enough, the player has to press the matching direction
  again once already on it.
- **`changeblock x, y, block_id` takes tile coordinates, like every other
  map-event macro — not the block-grid position you'd read off a `.blk`
  ASCII layout.** Getting this wrong doesn't error, it silently edits the
  wrong cell. If a `changeblock` looks like a no-op, dump
  `wOverworldMapBlocks` before/after rather than assuming the command
  itself is broken.
- **A live `changeblock` may not update collision on a map too small to
  scroll**, even paired with `refreshmap` (the pattern `TeamRocketBaseB2F`'s
  locked door uses successfully on a large map). Confirmed by direct memory
  read: the block byte was correctly rewritten, but the player stayed
  blocked walking onto it in the same session. Swapping to `changeblock` +
  `reloadmap` (a full reload) fixed it. Verify a same-screen block edit on
  a small map before trusting `refreshmap` there.
- **Don't `applymovement` a script-interactive object to imply "it moved."**
  The Vermilion Port crate did this (shifted one tile via `slow_step` to
  "reveal" a hollow) and went permanently dead to interaction afterward —
  the shift landed it on the exact tile the (stationary) player was
  standing on, and `CheckFacingObject` can never resolve a facing tile
  equal to the player's own square, from any direction. The object was
  never broken; it just became topologically unreachable. Let the dialogue
  carry the "it moved" beat and leave the object's coordinate alone.
- **Catching a Transformed Pokémon always yields a Ditto** — vanilla bug in
  `engine/items/item_effects.asm`. METRONOME can reach TRANSFORM; it is not
  in `MetronomeExcepts`.
- **`hJoyDown` is a stale mirror** refreshed only by an explicit `GetJoypad`.
  Use `hJoypadDown` for live input.
- **`ReceiveItem` reads the item from `wCurItem`, not from `de`.** It routes
  to the correct pocket by the item's own attribute regardless of `hl`.
- **The Gen 1 truck is a map block, not a sprite** — that is why it was never
  interactive in Red/Blue. Ported here as `TILESET_PORT` block `$40` (tiles
  96–103, lifted from pokered's `ship_port`). Interaction is a `bg_event`,
  since a block cannot be an `object_event`.
- **Adding tiles to a tileset means four files**: the `.png`, `_metatiles.bin`
  (16 bytes per block), `_collision.asm` (one `tilecoll` per block), and
  `_palette_map.asm` (one `tilepal` per 8 tiles). Miss one and it either
  fails to assemble or renders with the wrong palette.
- **Pic banks 1–19 are at capacity.** New sprites go in `SECTION "Pics 20"`
  or later.
- **Species cap is 253.** Slot 252 is Gorochu; one remains. Past 253 requires
  rebuilding the index system — nobody in the Gen 2 scene has done it.
- Adding a species touches ~15 parallel tables. Add the constant first and
  let rgbasm name each table that needs an entry. Watch for placeholder rows
  sitting *after* an `assert_table_length`.
- Introducing a global label mid-script resets local (`.foo`) label scope.
- `closetext` is only valid when text is actually open.
