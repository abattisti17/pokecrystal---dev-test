#!/usr/bin/env python3
"""
Pokémon: Lost Legends -- headless test harness.

Boots the devwarp ROM in PyBoy and asserts on real game memory. This exists
because a clean `make` proves nothing about runtime: every bug found on device
so far (garbage player name, wOTPartyCount corruption, an object placed over
water, a Mew that caught as a Ditto) assembled without a single warning.

Checks are grouped by feature so you can run only what you're working on:

    python3 test/smoke_test.py ROM                  # everything applicable
    python3 test/smoke_test.py ROM --only core      # just the fast-start
    python3 test/smoke_test.py ROM --only mew
    python3 test/smoke_test.py ROM --list           # show groups

CONVENTION (see CLAUDE.md):
  - While iterating on a feature, run --only <that feature>.
  - Before pushing, run the full suite with no flags.
  - CI always runs the full suite. Selection is a local speed-up only; it is
    never the safety net. Feature isolation is weaker than it looks here --
    intro_menu.asm and the shared species tables are touched by almost
    everything.

Groups declare the devwarp spawn they need. If the ROM under test spawns
somewhere else, the group SKIPS and says so. A skip is not a pass -- it means
that coverage did not run, and it is printed loudly on purpose.
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
    "wMoney": 0xD84E,
    "wNumBalls": 0xD8D7,
}

CYNDAQUIL = 155
GOROCHU = 252
STRENGTH = 70
ULTRA_BALL = 2

VERMILION_PORT = (15, 2)  # (map group, map number)


def decode_name(raw):
    """Gen 2 text encoding: 'A'-'Z' start at 0x80, terminator is 0x50."""
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


def boot(rom_path):
    """Boot to a settled overworld and return the PyBoy instance."""
    pb = PyBoy(str(rom_path), window="null", cgb=True, sound_emulated=False)
    for frame in range(900):
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
    return pb


def current_spawn(pb):
    return (pb.memory[ADDR["wMapGroup"]], pb.memory[ADDR["wMapNumber"]])


# --------------------------------------------------------------------------
# Check groups
# --------------------------------------------------------------------------

def check_core(pb):
    """Devwarp fast-start: name, party, and testing loadout."""
    m = pb.memory
    name = decode_name([m[ADDR["wPlayerName"] + i] for i in range(8)])
    party_count = m[ADDR["wPartyCount"]]
    species = m[ADDR["wPartySpecies"]]
    species2 = m[ADDR["wPartySpecies"] + 1]
    moves = [m[ADDR["wPartyMon1Moves"] + i] for i in range(4)]
    money = (m[ADDR["wMoney"]] << 16) | (m[ADDR["wMoney"] + 1] << 8) | m[ADDR["wMoney"] + 2]
    ball_id = m[ADDR["wNumBalls"] + 1]
    ball_qty = m[ADDR["wNumBalls"] + 2]

    return [
        ("player name is DEV", name == "DEV"),
        ("two party members", party_count == 2),
        ("starter is Cyndaquil", species == CYNDAQUIL),
        ("slot 2 is Gorochu", species2 == GOROCHU),
        ("starter knows Strength", STRENGTH in moves),
        ("testing money granted", money == 999999),
        ("Ultra Balls in Balls pocket", ball_id == ULTRA_BALL and ball_qty == 99),
    ]


def check_mew(pb):
    """The Vermilion Port crate. Requires a Vermilion Port devwarp spawn."""
    return [
        ("spawned in Vermilion Port", current_spawn(pb) == VERMILION_PORT),
    ]


GROUPS = {
    "core": {
        "fn": check_core,
        "desc": "devwarp fast-start: name, party, testing loadout",
        "requires_spawn": None,  # spawn-agnostic
    },
    "mew": {
        "fn": check_mew,
        "desc": "Vermilion Port crate / Mew encounter",
        "requires_spawn": VERMILION_PORT,
    },
}


# --------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rom", nargs="?")
    ap.add_argument("--out", default="artifacts")
    ap.add_argument("--only", action="append", default=None,
                    help="run only this group (repeatable)")
    ap.add_argument("--list", action="store_true", help="list groups and exit")
    args = ap.parse_args()

    if args.list:
        print("Available groups:\n")
        for tag, g in GROUPS.items():
            need = g["requires_spawn"]
            need_s = "any spawn" if need is None else f"spawn {need}"
            print(f"  {tag:<10} {g['desc']}  [{need_s}]")
        return 0

    if not args.rom:
        ap.error("ROM path required")
    rom = Path(args.rom)
    if not rom.exists():
        print(f"ROM not found: {rom}", file=sys.stderr)
        return 2

    selected = args.only or list(GROUPS)
    unknown = [t for t in selected if t not in GROUPS]
    if unknown:
        print(f"Unknown group(s): {', '.join(unknown)}", file=sys.stderr)
        print(f"Known: {', '.join(GROUPS)}", file=sys.stderr)
        return 2

    pb = boot(rom)
    spawn = current_spawn(pb)
    print(f"devwarp spawn: map group {spawn[0]}, map {spawn[1]}\n")

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    try:
        pb.screen.image.convert("RGB").save(out_dir / "smoke_overworld.png")
    except Exception as e:  # screenshot is a nice-to-have
        print(f"screenshot skipped: {e}")

    failed = 0
    skipped = []
    for tag in selected:
        g = GROUPS[tag]
        need = g["requires_spawn"]
        if need is not None and spawn != need:
            skipped.append((tag, need))
            continue
        print(f"[{tag}]")
        for label, ok in g["fn"](pb):
            print(f"  {'PASS' if ok else 'FAIL'}  {label}")
            if not ok:
                failed += 1
        print()

    pb.stop()

    for tag, need in skipped:
        print(f"  SKIP  [{tag}] not run -- needs devwarp spawn {need}, ROM spawns {spawn}")
    if skipped:
        print("  A skip is not a pass. That coverage did not run.\n")

    if failed:
        print(f"{failed} check(s) failed.")
        return 1
    print("All selected checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
