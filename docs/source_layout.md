# Source Layout

`src/main.asm` includes the modules in CPU address order; moving an include
moves bytes, so `make verify` fails. The cartridges, FDS SMB1 and All Night
Nippon's main program include it from their entry files (`src/revisions/`, see
[revisions](revisions.md)); Super Mario Bros. 2 has its own tree. The build's
`.map` and `.lbl` files give each module's addresses; this page gives what
each one is for.

All linker configs live in `config/linker/`: `nrom256.cfg` for the cartridges
(header, PRG at `$8000-$FFF9`, the vectors and the CHR),
`nrom256_relocated.cfg` for the relocated JU build, `fds_prg.cfg` for FDS
SMB1, and `ann.cfg` and `smb2.cfg` for the two later disks, which write one
file per disk program file.

## Granularity Policy

A module owns a coherent subsystem, its closely related helper routines, and
the data those routines consume. Small routines are not split into separate
files merely to mirror a call graph or satisfy a line limit. Typical modules
are a few hundred lines; 700 lines is a soft upper limit, not a mandate to
fragment cohesive code.

## Modules

| File | Responsibility |
| --- | --- |
| `src/memory/hardware.inc` | NES hardware registers |
| `src/memory/ram.inc` | Zero-page and RAM aliases |
| `src/memory/constants.inc` | Sound, music, object, input, and mode constants |
| `src/main.asm` | The address-ordered include index; the relocation probes |
| `src/system/boot_and_frame.asm` | Reset, NMI frame driver, timers, pause, sprite shuffling, and mode dispatch |
| `src/game/modes.asm` | Title, demo, victory, and floating-score flow |
| `src/rendering/screens.asm` | Screen tasks, palettes, text, and title-screen transfer |
| `src/rendering/background.asm` | Area rendering, attributes, metatiles, palettes, and messages |
| `src/system/hardware_io.asm` | Jump dispatch, controller input, PPU buffers, and nametable initialization |
| `src/rendering/hud/status.asm` | Status digits, score arithmetic, and top-score updates |
| `src/platforms/vs/system.asm` | Vs. System hardware services (Vs. only) |
| `src/game/setup_and_transitions.asm` | Game/area setup, entrances, life loss, and game over |
| `src/game/level/parser.asm` | Column parser, scenery, terrain, and area-object dispatch |
| `src/game/level/special_objects.asm` | Area attributes, ledges, castles, pipes, and scroll locks |
| `src/game/level/terrain_objects.asm` | Holes, bridges, blocks, cannons, stairs, springs, and buffer helpers |
| `src/platforms/vs/levels.asm` | Vs. course loader and CHR-resident course indexes (Vs. only) |
| `src/data/levels/index_and_enemies.asm` | Area lookup tables and bounded enemy-stream assets |
| `src/data/levels/areas.asm` | Bounded area-object stream assets |
| `src/game/gameplay_core.asm` | Game-mode routine: the per-frame engine and, on Vs., the two-player joypad merge |
| `src/game/core.asm` | Game mode, scrolling, player control states, and area transitions |
| `src/game/player/physics.asm` | Walking, running, jumping, swimming, climbing, and friction |
| `src/game/objects/projectiles_and_interactions.asm` | Fireballs, bubbles, timer, warp zones, flagpole, spring, and vine |
| `src/game/objects/dynamic.asm` | Cannons, bullets, hammers, coins, scoring, and power-ups |
| `src/game/objects/blocks.asm` | Player/block interaction, brick chunks, and block runtime |
| `src/game/physics/movement.asm` | Shared horizontal, vertical, and gravity movement primitives |
| `src/game/enemies/stream_and_initialization.asm` | Enemy stream parsing, loop commands, and common initialization |
| `src/game/enemies/special_initialization.asm` | Firebars, flying enemies, Bowser, groups, and platforms |
| `src/game/enemies/runtime.asm` | Enemy dispatcher and common movement behaviors |
| `src/game/enemies/special_behaviors.asm` | Firebars, flying Cheep-Cheeps, and Lakitu/Spiny behavior |
| `src/game/enemies/bowser_and_goals.asm` | Bowser, bridge collapse, fireworks, star flag, and Piranha Plant |
| `src/game/platforms.asm` | Balance, moving, falling, and lift platforms |
| `src/game/collisions/projectiles.asm` | Fireball/enemy, hammer/player, and power-up collisions |
| `src/game/collisions/actors.asm` | Player/enemy, enemy/enemy, and platform collisions |
| `src/game/collisions/platform_positioning.asm` | Player positioning on small and vertical platforms |
| `src/game/collisions/player_background.asm` | Player metatile collision, climbing, pipes, coins, and movement blocking |
| `src/game/collisions/enemy_background.asm` | Enemy and fireball interactions with background metatiles |
| `src/game/collisions/bounding_boxes.asm` | Bounding-box construction and generic overlap/block-buffer tests |
| `src/rendering/actors/misc.asm` | Vines, hammers, flags, platforms, coins, and power-ups |
| `src/rendering/actors/enemies.asm` | Enemy graphics selection, animation, mirroring, and OAM rows |
| `src/rendering/actors/objects.asm` | Blocks, brick chunks, fireballs, explosions, platforms, and bubbles |
| `src/rendering/actors/player.asm` | Player graphics, animation, sizing, attributes, and OAM output |
| `src/rendering/positioning.asm` | Relative coordinates, offscreen bits, and generic sprite composition |
| `src/audio/sound_effects.asm` | Audio dispatcher and square/noise sound effects |
| `src/audio/music_engine.asm` | Music headers, channel sequencing, lengths, and envelopes |
| `src/audio/music_data.asm` | Relocatable music indexes and address-bearing headers |
| `src/audio/music_streams.asm` | Profile-selected note streams, frequency tables, and envelopes |
| `src/data/vectors.asm` | NMI, reset, and IRQ vectors |

The All Night Nippon program adds its disk loader, title, course and ending
modules from `src/platforms/late_fds/ann/` before the audio code (see
`src/main.asm`); its overlay files and Super Mario Bros. 2 have their own
entry files in `src/revisions/ann/` and `src/revisions/smb2/`, with their code
in `src/platforms/late_fds/`.
