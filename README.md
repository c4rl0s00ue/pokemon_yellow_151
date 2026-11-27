# Pokémon Yellow 151

Patches a **Pokémon Yellow: Special Pikachu Edition** backup ROM so all 151 Pokémon are obtainable **without a cable link**: through wild encounters, in-game trades, Game Corner prizes, evolution stones and leveling.

The patcher is available as a Python script and as a PowerShell script. Both produce the exact same ROM.

> **This repository contains no game data.** No ROM, no Nintendo/Game Freak code or assets. The scripts only hold a list of small byte changes, which they apply to a copy of the game that **you** provide.

## What it changes

| Area | Change |
|---|---|
| Trade evolutions | Kadabra → Alakazam (lvl 30), Graveler → Golem (lvl 36), Machoke → Machamp (lvl 36), Haunter → Gengar (lvl 33) |
| Raichu | The starter Pikachu can evolve with a Thunder Stone |
| Wild encounters | Weedle and Kakuna (Viridian Forest), Ekans (Route 4), Meowth (Routes 5 and 6), Koffing (Pokémon Mansion), Electabuzz (Power Plant) |
| Game Corner prizes | Eevee, Mew, Jynx and Magmar replace Abra, Wigglytuff, Scyther and Pinsir; Eevee, Vulpix and Mew prices are adjusted |
| Fighting Dojo | Take **both** Hitmonlee and Hitmonchan |
| Mt. Moon | Take **both** fossils (Helix and Dome) |

Evolutions cover the rest: Beedrill, Arbok, Persian and Weezing come from evolving what you catch, and Mr. Mime comes from the in-game Clefairy trade. Eevee is a prize that can be bought repeatedly, so you can get one for each evolution (the Celadon shops sell the Fire, Water, Thunder and Leaf stones).

### Full Pokémon list

See [pokemon_list.md](pokemon_list.md) for all 151 Pokémon, where to find each one, and a 🆕 **Added** tag on the ones this patch makes obtainable.

## Requirements

- A legally obtained backup of your own **Pokémon Yellow: Special Pikachu Edition (USA, Europe)** `.gb` file (GBC/SGB Enhanced, 1,048,576 bytes).
- One of:
  - **Python 3.8+** (any OS), or
  - **Windows PowerShell 5.1+** (included with Windows 10/11).
- No third-party packages.

Other versions and languages (Red, Blue, Japanese, etc.) are **not** supported. The patcher checks the original bytes and refuses to run on a different ROM.

## Usage

Python:

```powershell
python Python/patch_pokemon_yellow.py "Pokemon-YellowVersion.gb"
```

On Windows you can use `py` instead of `python`.

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\Powershell\Patch-PokemonYellow.ps1 -InputRom "Pokemon-YellowVersion.gb"
```

The result is written next to the input as `Pokemon Yellow - Complete.gb`. Choose another path with `-o` (Python) or `-OutputRom` (PowerShell). Your original file is never modified.

Load the patched ROM in your emulator or flash cart as usual.

## Safety checks

- Every patch verifies the original bytes first, so a wrong or already-patched ROM is rejected instead of being corrupted.
- The ROM header and global checksums are recalculated.

## Status and known issues

- The data changes (evolutions, wild encounters, prizes) are straightforward.
- The **Dojo, Mt. Moon and Raichu** patches change game code by hand and are **still being playtested**.
- After evolving the starter Pikachu, the following sprite may stay a Pikachu.
- **Use a copy of your save** the first time, and keep the original ROM.

Found a problem? Open an issue and say where it happened and what you saw.

## Legal

This is an unofficial fan project, not affiliated with or endorsed by Nintendo, Game Freak, Creatures Inc. or The Pokémon Company. Pokémon and Pokémon character names are trademarks of their respective owners.

You are responsible for making sure you own the game you patch. Do not ask for, share or upload ROMs in this repository's issues or pull requests.

## License

Released under the **GNU General Public License v3.0**. See [LICENSE](LICENSE).

The software is provided **"as is", without warranty of any kind**, express or implied, including merchantability, fitness for a particular purpose and non-infringement. The authors are not liable for any damage, including corrupted saves or ROMs, arising from its use.

The license applies to these scripts only, not to the game or any ROM.

## Contributing

Ideas and fixes are welcome. Patches are plain data in the `build_patches()` function (Python) and in the matching blocks of the PowerShell script. If you change one, change the other and check that both still produce an identical ROM.
