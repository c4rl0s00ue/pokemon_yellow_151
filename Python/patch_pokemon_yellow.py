#!/usr/bin/env python3
"""
(EN)
Patches a Pokemon Yellow backup ROM so all 151 Pokemon are obtainable via wild
encounters, in-game trades, evolution stones and leveling, without a cable link.
The input file is never modified; a wrong or already-patched ROM is rejected.

(ES)
Parchea una ROM de respaldo de Pokemon Amarillo para que los 151 Pokemon se
puedan obtener en estado salvaje, intercambios dentro del juego, piedras
evolutivas y subiendo de nivel, sin cable link. El archivo original nunca se
modifica; una ROM incorrecta o ya parcheada se rechaza.

(FR)
Modifie une ROM de sauvegarde de Pokemon Jaune pour que les 151 Pokemon soient
obtenables a l'etat sauvage, par echanges dans le jeu, pierres d'evolution et
niveaux, sans cable Link. Le fichier d'origine n'est jamais modifie ; une ROM
incorrecte ou deja patchee est rejetee.

(ZH)
为宝可梦黄版备份 ROM 打补丁,使全部 151 只宝可梦无需联机线即可获得:
野生捕捉、游戏内交换、进化石和升级进化。原始文件不会被修改;
错误或已打过补丁的 ROM 会被拒绝。

(JA)
ポケットモンスター ピカチュウ版のバックアップROMにパッチを当て、通信ケーブルなしで
151匹すべてを入手可能にします(野生、ゲーム内交換、進化の石、レベルアップ)。
元のファイルは変更されません。違うROMや適用済みROMは拒否されます。

Usage / Uso / Utilisation / 用法 / 使い方:
    python patch_pokemon_yellow.py "Pokemon - Yellow Version ... .gb" [-o "Pokemon Yellow - Complete.gb"]
"""
import argparse
import os
import sys

# internal species indices (not Pokedex numbers)
WEEDLE, KAKUNA, CATERPIE, EKANS, SPEAROW, MEOWTH = 0x70, 0x71, 0x7B, 0x6C, 0x05, 0x4D
PIDGEY, KOFFING, GRIMER, ELECTABUZZ, EEVEE, MEW = 0x24, 0x37, 0x0D, 0x35, 0x66, 0x15
JYNX, MAGMAR, ABRA, WIGGLY, SCYTHER, PINSIR = 0x48, 0x33, 0x94, 0x65, 0x1A, 0x1D
VULPIX, PORYGON = 0x52, 0xAA


def build_patches():
    """Return a list of (section, offset, expected_bytes, new_bytes, description)."""
    p = []

    def add(section, off, old, new, what):
        p.append((section, off, bytes(old), bytes(new), what))

    def slot(section, rec, idx, old_l, old_s, new_l, new_s, what):
        add(section, rec + 1 + idx * 2, [old_l, old_s], [new_l, new_s], what)

    s = "Trade evolutions -> level evolutions"
    add(s, 0x3B555, [3, 1, 0x95, 0], [1, 30, 0x95, 0], "Kadabra -> Alakazam (lvl 30)")
    add(s, 0x3B566, [3, 1, 0x31, 0], [1, 36, 0x31, 0], "Graveler -> Golem (lvl 36)")
    add(s, 0x3B587, [3, 1, 0x7E, 0], [1, 36, 0x7E, 0], "Machoke -> Machamp (lvl 36)")
    add(s, 0x3B9C6, [3, 1, 0x0E, 0], [1, 33, 0x0E, 0], "Haunter -> Gengar (lvl 33)")

    s = "Wild encounters"
    slot(s, 0xCDCD, 0, 3, CATERPIE, 3, WEEDLE, "Viridian Forest: Weedle")
    slot(s, 0xCDCD, 2, 4, CATERPIE, 4, WEEDLE, "Viridian Forest: Weedle")
    slot(s, 0xCDCD, 6, 6, CATERPIE, 6, KAKUNA, "Viridian Forest: Kakuna")
    slot(s, 0xCE3B, 3, 10, SPEAROW, 10, EKANS, "Route 4: Ekans")
    slot(s, 0xCE3B, 8, 11, SPEAROW, 11, EKANS, "Route 4: Ekans")
    for rec, name in ((0xCE93, "Route 5"), (0xCEA9, "Route 6")):
        slot(s, rec, 3, 16, PIDGEY, 14, MEOWTH, name + ": Meowth")
        slot(s, rec, 5, 17, PIDGEY, 16, MEOWTH, name + ": Meowth")
    slot(s, 0xD1A5, 2, 23, GRIMER, 24, KOFFING, "Pokemon Mansion 1F: Koffing")
    slot(s, 0xD1A5, 7, 26, GRIMER, 28, KOFFING, "Pokemon Mansion 1F: Koffing")
    slot(s, 0xD1BB, 2, 26, GRIMER, 28, KOFFING, "Pokemon Mansion 2F: Koffing")
    slot(s, 0xD1BB, 3, 29, GRIMER, 31, KOFFING, "Pokemon Mansion 2F: Koffing")
    slot(s, 0xD1D1, 2, 32, GRIMER, 33, KOFFING, "Pokemon Mansion 3F: Koffing")
    slot(s, 0xD1D1, 3, 35, GRIMER, 35, KOFFING, "Pokemon Mansion 3F: Koffing")
    slot(s, 0xD269, 5, 33, GRIMER, 33, ELECTABUZZ, "Power Plant: Electabuzz")
    slot(s, 0xD269, 6, 37, GRIMER, 36, ELECTABUZZ, "Power Plant: Electabuzz")

    s = "Game Corner prizes"
    add(s, 0x527BA, [ABRA, VULPIX, WIGGLY], [EEVEE, VULPIX, MEW], "Prize list 1: Eevee / Vulpix / Mew")
    add(s, 0x527BE, [0x02, 0x30, 0x10, 0x00, 0x26, 0x80], [0x12, 0x00, 0x10, 0x00, 0x99, 0x99],
        "Prize list 1 prices (1200/1000/9999)")
    add(s, 0x527C5, [SCYTHER, PINSIR, PORYGON], [JYNX, MAGMAR, PORYGON], "Prize list 2: Jynx / Magmar / Porygon")
    add(s, 0x528EA,
        [ABRA, 0x0F, VULPIX, 0x12, WIGGLY, 0x16, SCYTHER, 0x1E, PINSIR, 0x1E, PORYGON, 0x1A],
        [EEVEE, 20, VULPIX, 0x12, MEW, 30, JYNX, 30, MAGMAR, 34, PORYGON, 0x1A], "Prize levels")

    s = "Fighting Dojo: take both Hitmons"
    add(s, 0x5CE00, [0xE6, 0xC0], [0xE6, 0x40], "Hitmonlee ball checks only its own flag")
    add(s, 0x5CE48, [0xE6, 0xC0], [0xE6, 0x80], "Hitmonchan ball checks only its own flag")

    s = "Mt. Moon: take both fossils"
    add(s, 0x49E06, [0x3E, 0x11, 0xCD, 0xB4, 0x3E], [0, 0, 0, 0, 0], "Other fossil no longer hidden")
    add(s, 0x4A0A6, [0x3E, 0x04], [0x3E, 0x00], "Dome fossil: keep script state 0")
    add(s, 0x4A0E3, [0x3E, 0x04], [0x3E, 0x00], "Helix fossil: keep script state 0")

    s = "Starter Pikachu can use evolution stones"
    add(s, 0xD808, [0x3E, 0x30, 0x25], [0x3E, 0x18, 0x25], "Pikachu -> Raichu not blocked")
    return p


def main():
    # make --help printable on non-UTF-8 Windows consoles (CJK text)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", help="original Pokemon Yellow .gb/.gbc backup")
    ap.add_argument("-o", "--output", help="output path (default: 'Pokemon Yellow - Complete.gb' next to input)")
    a = ap.parse_args()

    src = os.path.abspath(a.input)
    if not os.path.isfile(src):
        sys.exit("Input ROM not found: " + src)
    out = os.path.abspath(a.output) if a.output else os.path.join(os.path.dirname(src), "Pokemon Yellow - Complete.gb")
    if out == src:
        sys.exit("Output must differ from input.")

    with open(src, "rb") as f:
        rom = bytearray(f.read())
    if len(rom) != 1048576:
        sys.exit("Unexpected ROM size %d (expected 1048576)." % len(rom))

    section = None
    for sec, off, old, new, what in build_patches():
        if sec != section:
            print(sec)
            section = sec
        if bytes(rom[off:off + len(old)]) != old:
            sys.exit("%s: unexpected bytes at 0x%X. Is this the right ROM?" % (what, off))
        rom[off:off + len(new)] = new
        print("  OK 0x%05X  %s" % (off, what))

    # header checksum, then global checksum
    h = 0
    for i in range(0x134, 0x14D):
        h = (h - rom[i] - 1) & 0xFF
    rom[0x14D] = h
    g = (sum(rom) - rom[0x14E] - rom[0x14F]) & 0xFFFF
    rom[0x14E], rom[0x14F] = g >> 8, g & 0xFF

    with open(out, "wb") as f:
        f.write(rom)
    print("\n%d patches applied. Checksums fixed.\nWritten: %s" % (len(build_patches()), out))


if __name__ == "__main__":
    main()
