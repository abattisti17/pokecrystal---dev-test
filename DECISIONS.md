# Design Decisions

**Read this before the design bible.** Where this file and
`PokemonLostLegends_DesignBible.docx` disagree, **this file wins.** The bible is
the original vision document; these are the decisions actually made during
development, including several that reverse it.

---

## The pillars, unchanged

1. Anime/manga stories never told in the games
2. Beta Pokémon made real — "the ones the professors forgot"
3. Playground myths made real
4. Authentic Gen 1/2 aesthetic

## Tone rules, unchanged

- Gen 2 register: short lines, plain words, implied threat.
- No winking at the camera. Myths are never confirmed by an NPC before the
  player discovers them; they only make sense in retrospect.
- Dark content is implied, never graphic.
- **No flashing, strobing, or rapid palette alternation, ever.** Safety
  requirement, not style.

---

## IN — decided and wanted

| Feature | Status | Notes |
|---|---|---|
| **Mew under the truck** | built | See "Mew" below — trigger changed from the bible |
| **Press B catch bonus** | built | Rewards *holding* B, never mashing — see below |
| **Gorochu** | species exists | Slot 252. Placeholder sprite; no evolution method yet |
| **Porygon / Transfer Network** | built | Three rooms, catchable Porygon |
| **MissingNo.** | wanted, not built | Must be hard-coded — see below |
| **Venustoise** | wanted, not built | Needs a species slot |
| **Giant Tentacruel** | wanted, not built | From "Tentacool & Tentacruel" |
| **Ho-Oh in the sky** | wanted, not built | The rainbow bird from episode 1 |
| **Beta Pokémon** | wanted | Each needs a species slot — see the cap below |

## CUT — do not build

- **A Mother's Promise (Marowak ghost quest).** Explicitly cut.

## TABLED — good ideas, deferred

- **The Pokégods.** Not disliked — the *label* was unfamiliar, and Venustoise
  and Pikablu are both on that list. Deferred because it means original sprite
  work, which is impractical from a phone. Revisit when there's an artist or a
  desktop.
- **The Soldier's War (Lt. Surge).** Interest expressed, direction unclear.
- **Sabrina's Origin, Bill's Other Experiment, The Maiden's Real Name.**
  From the bible's side-quest list; not prioritised.

---

## Decisions that reverse the bible

### Mew's trigger
The bible specifies S.S. Aqua ticket + Cut + Surf + Old Lure, Lv.5, no retry.
**Superseded.** Research showed most versions of the actual playground rumor
said to use **Strength** on the truck. Built as: Strength + Plain Badge, Lv30,
**with** a DRAW failsafe so it is recoverable.

The bible's Lv.5 would have avoided a bug by accident — see RESEARCH.md on
Transform. Its constraints sometimes encode reasons that aren't obvious.

### Press B rewards holding, not mashing
A permanent design constraint, not a bug. The catch roll fires the instant
"USE" is confirmed, and B is the bag's cancel button at that moment, so a fresh
press is always consumed by the menu. A *held* B works because cancel fires on
the press edge. Holding is also the more historically common version of the
rumor, so this is faithful. **Do not "fix" this into mash support.**

### MissingNo. must be hard-coded
It cannot occupy an "empty slot" — the emptiness *is* the phenomenon, and
pokecrystal has no usable empty slots anyway. It costs a real species slot.
Simulate the corruption (a glitchy sprite, odd name, scripted effects); never
actually corrupt anything.

### The truck is scenery, not a sprite
In Gen 1 it was a map block, which is exactly why it was never interactive.
Ported faithfully as a block; interaction is a `bg_event`.

---

## The hard constraint: species slots

**The cap is 253.** Gorochu holds 252; **one slot remains.** Going past 253
means rebuilding the one-byte species index — nobody in the Gen 2 scene has
done it, and Pokémon Prism, the most ambitious Gen 2 hack ever made, stopped at
exactly 253 and swapped species out rather than adding.

MissingNo., Venustoise, and every beta Pokémon each cost one slot.

**Approved for removal** (no evolution family, no trainer use, no script
references — cheapest to replace): Gligar, Misdreavus, Smeargle, Stantler.
Then, with dependencies to fix: Yanma, Wobbuffet, Snubbull line, Spearow line,
Arbok line, Venomoth line, Farfetch'd. Total available ≈ 17 slots.

Expensive ones, because they cost real content: **Unown** (15 script refs, the
Ruins of Alph puzzle), **Farfetch'd** (Ilex Forest quest), **Spearow/Fearow**
(Falkner's team, 56 wild spawns).

Note **Unown is one species slot, not 26** — the 26 letters are a *form*
selected from DVs. It is also the in-engine proof that the variant technique
works, and the model to copy if the Pokégods are ever revived.

---

## Working relationship

- **Claude (this chat):** research, diagnosis, specs, design decisions.
- **Claude Code (Sonnet):** implementation against a written spec.
- Ambiguous specs are the main failure mode. "Reuse layouts" once produced
  three rooms that were `INCBIN` copies of existing maps. Be explicit.
- Neither model catches runtime bugs from a clean build. Every bug found on
  device so far assembled without a warning.
- **Rosso has been right and the analysis wrong more than once** — notably the
  unreachable truck, caught by playing in a minute after a flood fill said
  otherwise. Playtest reports outrank analysis.
