#!/usr/bin/env python3
"""
Pokémon: Lost Legends -- headless smoke test.

Boots the devwarp ROM in PyBoy, mashes through the title screen into a new
game, then asserts on actual game memory that the fast-start worked. Saves a
screenshot either way so failures are inspectable.

This exists because a clean `make` proves nothing about runtime. Every bug
found on device so far (garbage player name, wOTPartyCount corruption, an
object placed over water) assembled without a single warning.

DEVWARP_SPAWN currently points at the Transfer Network vignette (see
constants/devwarp_constants.asm), so this test walks the network's three
rooms end to end: Entry -> Blockade -> Deep Node -> the Porygon encounter.
If DEVWARP_SPAWN is repointed at a different vignette, this test's route
needs to move with it.

Usage:
    python3 test/smoke_test.py pokecrystal_devwarp.gbc [--out artifacts/]
"""

import argparse
import logging
import sys
from pathlib import Path

logging.getLogger("pyboy").setLevel(logging.ERROR)

from pyboy import PyBoy  # noqa: E402

# WRAM addresses -- keep in sync with pokecrystal_devwarp.sym
ADDR = {
    "wPlayerName": 0xD47D,
    "wMapGroup": 0xDCB5,
    "wMapNumber": 0xDCB6,
    "wPartyCount": 0xDCD7,
    "wPartySpecies": 0xDCD8,
    "wPartyMon1Moves": 0xDCE1,
    "wEnemyMonSpecies": 0xD206,
    "wBattleMode": 0xD22D,
}

CYNDAQUIL = 155
GOROCHU = 252
PORYGON = 137
STRENGTH = 70
TRANSFER_NETWORK_ENTRY = (27, 1)  # (map group, map number)
TRANSFER_NETWORK_BLOCKADE = (27, 2)
TRANSFER_NETWORK_DEEP_NODE = (27, 3)

# Gen 2 text encoding: 'A'-'Z' start at 0x80, terminator is 0x50
def decode_name(raw):
    out = []
    for b in raw:
        if b == 0x50:
            break
        if 0x80 <= b <= 0x99:
            out.append(chr(b - 0x80 + ord("A")))
        elif 0xA0 <= b <= 0xB9:
            out.append(chr(b - 0xA0 + ord("a")))
        else:
            out.append("?")
    return "".join(out)


def hold(pb, button, frames=24, settle=8):
    pb.button_press(button)
    for _ in range(frames):
        pb.tick()
    pb.button_release(button)
    for _ in range(settle):
        pb.tick()


def tap(pb, button, gap=150, press=3):
    pb.button(button, delay=press)
    for _ in range(gap):
        pb.tick()


def run(rom_path, out_dir, frames_to_newgame=900):
    pb = PyBoy(str(rom_path), window="null", cgb=True, sound_emulated=False)

    # Mash A/START through the title screen and into a new game.
    for frame in range(frames_to_newgame):
        if frame % 20 == 0:
            pb.button("a", delay=3)
        elif frame % 20 == 10:
            pb.button("start", delay=3)
        pb.tick()

    # Close any menu START left open, then let the overworld settle.
    for _ in range(4):
        pb.button("b", delay=3)
        for _ in range(30):
            pb.tick()
    for _ in range(120):
        pb.tick()

    mem = pb.memory
    name = decode_name([mem[ADDR["wPlayerName"] + i] for i in range(8)])
    group = mem[ADDR["wMapGroup"]]
    number = mem[ADDR["wMapNumber"]]
    party_count = mem[ADDR["wPartyCount"]]
    species = mem[ADDR["wPartySpecies"]]
    species2 = mem[ADDR["wPartySpecies"] + 1]
    moves = [mem[ADDR["wPartyMon1Moves"] + i] for i in range(4)]

    out_dir.mkdir(parents=True, exist_ok=True)
    shot = out_dir / "smoke_overworld.png"
    try:
        pb.screen.image.convert("RGB").save(shot)
    except Exception as e:  # screenshot is a nice-to-have; never fail the checks over it
        print(f"screenshot skipped: {e}")
        shot = None

    # Walk the Transfer Network end to end: Entry's doorway to Blockade,
    # Blockade's doorway deeper to the Deep Node, then up to the Porygon
    # encounter itself. Every leg is the exact route confirmed by hand in
    # PyBoy; see BRANCHES.md for the "Transfer Network" vignette writeup.
    room_walk = (
        ["down"] * 2 + ["left"] * 4 + ["up"] * 4 + ["right"] * 8 + ["left"]
    )

    # -- Entry: reach the doorway at (6,1) and go through to Blockade.
    for d in room_walk:
        hold(pb, d)
    tap(pb, "up", gap=30)
    tap(pb, "a", gap=150)
    tap(pb, "a", gap=150)
    hold(pb, "down", frames=5)

    reached_blockade = (
        mem[ADDR["wMapGroup"]],
        mem[ADDR["wMapNumber"]],
    ) == TRANSFER_NETWORK_BLOCKADE

    # -- Blockade: same room shape (reused layout), reach its own doorway
    # deeper at (6,1) and go through to the Deep Node.
    for d in room_walk:
        hold(pb, d)
    tap(pb, "up", gap=30)
    for _ in range(4):
        tap(pb, "a", gap=150)
    hold(pb, "down", frames=5)

    reached_deep_node = (
        mem[ADDR["wMapGroup"]],
        mem[ADDR["wMapNumber"]],
    ) == TRANSFER_NETWORK_DEEP_NODE

    # -- Deep Node: walk up to the source and face it.
    approach = [
        "left", "up", "up", "up", "up", "up", "up", "up", "right", "up",
    ]
    for d in approach:
        hold(pb, d)
    hold(pb, "right")  # face the Porygon object

    enemy_species = 0
    battle_mode = 0
    for frame in range(3000):
        if frame % 15 == 0:
            pb.button("a", delay=3)
        pb.tick()
        enemy_species = mem[ADDR["wEnemyMonSpecies"]]
        battle_mode = mem[ADDR["wBattleMode"]]
        if enemy_species == PORYGON and battle_mode != 0:
            break
    print(f"enemy species: {enemy_species} (battle_mode={battle_mode})")

    pb.stop()

    print(f"player name : {name!r}")
    print(f"map         : group {group}, number {number}")
    print(f"party count : {party_count}")
    print(f"species     : {species}, {species2}")
    print(f"moves       : {moves}")
    print(f"screenshot  : {shot}")
    print(f"reached Blockade  : {reached_blockade}")
    print(f"reached Deep Node : {reached_deep_node}")

    checks = [
        ("player name is DEV", name == "DEV"),
        ("spawned in Transfer Network Entry", (group, number) == TRANSFER_NETWORK_ENTRY),
        ("two party members", party_count == 2),
        ("starter is Cyndaquil", species == CYNDAQUIL),
        ("slot 2 is Gorochu", species2 == GOROCHU),
        ("starter knows Strength", STRENGTH in moves),
        ("Blockade room reachable from Entry", reached_blockade),
        ("Deep Node reachable from Blockade", reached_deep_node),
        ("wild battle entered (vs Porygon)", battle_mode != 0 and enemy_species == PORYGON),
    ]

    print()
    failed = 0
    for label, ok in checks:
        print(f"  {'PASS' if ok else 'FAIL'}  {label}")
        if not ok:
            failed += 1
    return failed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rom")
    ap.add_argument("--out", default="artifacts")
    args = ap.parse_args()

    rom = Path(args.rom)
    if not rom.exists():
        print(f"ROM not found: {rom}", file=sys.stderr)
        return 2

    failed = run(rom, Path(args.out))
    print()
    if failed:
        print(f"{failed} check(s) failed.")
        return 1
    print("All checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
