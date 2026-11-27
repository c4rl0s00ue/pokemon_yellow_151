<#
.SYNOPSIS
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

.USAGE / Uso / Utilisation / 用法 / 使い方:
  powershell -ExecutionPolicy Bypass -File .\Patch-PokemonYellow.ps1 -InputRom "Pokemon - Yellow Version....gb"
  (optional) -OutputRom "Pokemon Yellow - Complete.gb"

  The input file is never modified. Every patch first checks the original bytes, so a
  wrong/different ROM is rejected instead of being corrupted.
#>
param(
  [Parameter(Mandatory=$true)][string]$InputRom,
  [string]$OutputRom = ""
)
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $InputRom)) { throw "Input ROM not found: $InputRom" }
$InputRom = (Resolve-Path -LiteralPath $InputRom).Path
if (-not $OutputRom) {
  $OutputRom = Join-Path (Split-Path $InputRom -Parent) "Pokemon Yellow - Complete.gb"
}
if ($OutputRom -eq $InputRom) { throw "Output must differ from input." }

[byte[]]$rom = [System.IO.File]::ReadAllBytes($InputRom)
if ($rom.Length -ne 1048576) { throw "Unexpected ROM size $($rom.Length) (expected 1048576)." }

$script:count = 0
function Patch([int]$off, [byte[]]$expect, [byte[]]$new, [string]$what) {
  for ($i = 0; $i -lt $expect.Length; $i++) {
    if ($rom[$off + $i] -ne $expect[$i]) {
      throw ("{0}: unexpected byte at 0x{1:X} (got {2:X2}, want {3:X2}). Is this the right ROM?" -f $what, ($off + $i), $rom[$off + $i], $expect[$i])
    }
  }
  for ($i = 0; $i -lt $new.Length; $i++) { $rom[$off + $i] = $new[$i] }
  $script:count++
  Write-Host ("  OK 0x{0:X5}  {1}" -f $off, $what)
}
# wild-encounter slot: record start, slot index, old (level,species), new (level,species)
function Slot([int]$rec, [int]$idx, [byte]$oL, [byte]$oS, [byte]$nL, [byte]$nS, [string]$what) {
  Patch ($rec + 1 + $idx * 2) @($oL, $oS) @($nL, $nS) $what
}

# internal species indices
$WEEDLE=0x70; $KAKUNA=0x71; $CATERPIE=0x7B; $EKANS=0x6C; $SPEAROW=0x05; $MEOWTH=0x4D
$PIDGEY=0x24; $KOFFING=0x37; $GRIMER=0x0D; $ELECTABUZZ=0x35; $EEVEE=0x66; $MEW=0x15
$JYNX=0x48; $MAGMAR=0x33; $ABRA=0x94; $WIGGLY=0x65; $SCYTHER=0x1A; $PINSIR=0x1D
$VULPIX=0x52; $PORYGON=0xAA

Write-Host "Trade evolutions -> level evolutions"
Patch 0x3B555 @(3,1,0x95,0) @(1,30,0x95,0) 'Kadabra -> Alakazam (lvl 30)'
Patch 0x3B566 @(3,1,0x31,0) @(1,36,0x31,0) 'Graveler -> Golem (lvl 36)'
Patch 0x3B587 @(3,1,0x7E,0) @(1,36,0x7E,0) 'Machoke -> Machamp (lvl 36)'
Patch 0x3B9C6 @(3,1,0x0E,0) @(1,33,0x0E,0) 'Haunter -> Gengar (lvl 33)'

Write-Host "Wild encounters"
Slot 0xCDCD 0 3 $CATERPIE 3 $WEEDLE 'Viridian Forest: Weedle'
Slot 0xCDCD 2 4 $CATERPIE 4 $WEEDLE 'Viridian Forest: Weedle'
Slot 0xCDCD 6 6 $CATERPIE 6 $KAKUNA 'Viridian Forest: Kakuna'
Slot 0xCE3B 3 10 $SPEAROW 10 $EKANS 'Route 4: Ekans'
Slot 0xCE3B 8 11 $SPEAROW 11 $EKANS 'Route 4: Ekans'
foreach ($r in @(@(0xCE93,'Route 5'), @(0xCEA9,'Route 6'))) {
  Slot $r[0] 3 16 $PIDGEY 14 $MEOWTH "$($r[1]): Meowth"
  Slot $r[0] 5 17 $PIDGEY 16 $MEOWTH "$($r[1]): Meowth"
}
Slot 0xD1A5 2 23 $GRIMER 24 $KOFFING 'Pokemon Mansion 1F: Koffing'
Slot 0xD1A5 7 26 $GRIMER 28 $KOFFING 'Pokemon Mansion 1F: Koffing'
Slot 0xD1BB 2 26 $GRIMER 28 $KOFFING 'Pokemon Mansion 2F: Koffing'
Slot 0xD1BB 3 29 $GRIMER 31 $KOFFING 'Pokemon Mansion 2F: Koffing'
Slot 0xD1D1 2 32 $GRIMER 33 $KOFFING 'Pokemon Mansion 3F: Koffing'
Slot 0xD1D1 3 35 $GRIMER 35 $KOFFING 'Pokemon Mansion 3F: Koffing'
Slot 0xD269 5 33 $GRIMER 33 $ELECTABUZZ 'Power Plant: Electabuzz'
Slot 0xD269 6 37 $GRIMER 36 $ELECTABUZZ 'Power Plant: Electabuzz'

Write-Host "Game Corner prizes"
Patch 0x527BA @($ABRA,$VULPIX,$WIGGLY) @($EEVEE,$VULPIX,$MEW) 'Prize list 1: Eevee / Vulpix / Mew'
Patch 0x527BE @(0x02,0x30,0x10,0x00,0x26,0x80) @(0x12,0x00,0x10,0x00,0x99,0x99) 'Prize list 1 prices (1200/1000/9999)'
Patch 0x527C5 @($SCYTHER,$PINSIR,$PORYGON) @($JYNX,$MAGMAR,$PORYGON) 'Prize list 2: Jynx / Magmar / Porygon'
Patch 0x528EA @($ABRA,0x0F,$VULPIX,0x12,$WIGGLY,0x16,$SCYTHER,0x1E,$PINSIR,0x1E,$PORYGON,0x1A) `
               @($EEVEE,20,$VULPIX,0x12,$MEW,30,$JYNX,30,$MAGMAR,34,$PORYGON,0x1A) 'Prize levels'

Write-Host "Fighting Dojo: take both Hitmons"
Patch 0x5CE00 @(0xE6,0xC0) @(0xE6,0x40) 'Hitmonlee ball checks only its own flag'
Patch 0x5CE48 @(0xE6,0xC0) @(0xE6,0x80) 'Hitmonchan ball checks only its own flag'

Write-Host "Mt. Moon: take both fossils"
Patch 0x49E06 @(0x3E,0x11,0xCD,0xB4,0x3E) @(0,0,0,0,0) 'Other fossil no longer hidden'
Patch 0x4A0A6 @(0x3E,0x04) @(0x3E,0x00) 'Dome fossil: keep script state 0'
Patch 0x4A0E3 @(0x3E,0x04) @(0x3E,0x00) 'Helix fossil: keep script state 0'

Write-Host "Starter Pikachu can use evolution stones"
Patch 0xD808 @(0x3E,0x30,0x25) @(0x3E,0x18,0x25) 'Pikachu -> Raichu not blocked'

# checksums
$h = 0
for ($i = 0x134; $i -le 0x14C; $i++) { $h = ($h - $rom[$i] - 1) -band 0xFF }
$rom[0x14D] = [byte]$h
$g = 0
for ($i = 0; $i -lt $rom.Length; $i++) { if ($i -ne 0x14E -and $i -ne 0x14F) { $g = ($g + $rom[$i]) -band 0xFFFF } }
$rom[0x14E] = [byte]($g -shr 8); $rom[0x14F] = [byte]($g -band 0xFF)

[System.IO.File]::WriteAllBytes($OutputRom, $rom)
Write-Host ""
Write-Host "$script:count patches applied. Checksums fixed."
Write-Host "Written: $OutputRom"
