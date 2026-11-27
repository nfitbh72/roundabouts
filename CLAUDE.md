# Working on Roundabouts Are Better

## How to work with me

- Suggest improvements regularly. Don't simply wait for instruction.
- Humour is important in this game, so add humour to our conversation. Douglas Adams is my favourite author, so the occasional quote or joke in that style is welcome.

## Rules

- Keep the project root with as few files as possible. Everything should be well structured in folders.
- Tidy code is very important to me. This codebase is likely to evolve a lot, so it needs to be very maintainable.
- Game logic and display must be kept separate at all times. Game logic should use pure functions wherever possible.
- For now, commit directly to `main` and push. We will set up agentic workflows and a proper PR process later.
- Always run `tools/check.sh` before pushing. It must finish with no errors and no warnings. Never push with a failing or noisy check, and never skip it because a change looks small.

## Project

- A light-hearted traffic light simulator. See `README.md` for the full description.
- Engine: Godot 4 (developed on 4.7.2), standard build with GDScript. Not the .NET build.
- Developed on macOS. Windows is the main release platform, through Steam.
- Remote: `origin` on GitHub, branch `main`.

## Folder layout

| Folder | Contents |
| --- | --- |
| `simulation/` | Game logic only. No rendering, no input, no scene tree. |
| `display/` | Scenes and scripts that draw the game and handle input. |
| `assets/` | Art, audio and fonts. |
| `tests/` | Automated tests, mirroring the folders they test. |
| `addons/` | Third-party Godot plugins, such as GUT and GodotSteam. Never edit these by hand. |
| `tools/` | Development scripts, such as the pre-commit check. |
| `docs/` | Decision records and design notes. |

Only files that tools require at the root live there: `project.godot`, `README.md`, `CLAUDE.md` and git config files.

## Keeping logic and display separate

- Code in `simulation/` must not extend `Node`, touch the scene tree, read input or draw anything. Use `RefCounted` classes and static functions.
- Code in `simulation/` must never reference anything in `display/`. Display reads simulation state and sends it commands, never the other way round.
- The simulation must be deterministic: the same level, program and random seed always give the same result. The roundabout wrap-up replays the same traffic, so this is a feature requirement. Pass the random number generator and the time step in as arguments. Never use global randomness or the wall clock in `simulation/`.
- Prefer pure functions: take state in, return new state, with no side effects.

## Code style

- Static typing everywhere: every variable, parameter and return value has a type.
- Follow the official GDScript style guide.
- Format with `gdformat` and lint with `gdlint` before every commit.
- British spelling in docs, comments and in-game text. American spelling in code identifiers, to match Godot's API (`color`, not `colour`).
- Small files and small functions. Split a file when it starts doing two jobs.

## Testing

- Tests use GUT and live in `tests/`.
- All new code in `simulation/` gets tests. Pure functions make this cheap.
- Run the tests before every commit.

## Commands

| Task | Command |
| --- | --- |
| Open the editor | `godot --editor --path .` |
| Run the game | `godot --path .` |
| Run every pre-commit check | `tools/check.sh` |
| Reformat, then run every check | `tools/check.sh --fix` |
| Run the tests only | `godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://tests/gutconfig.json` |

`tools/check.sh` checks formatting, lints, loads the project headlessly and runs the tests. It covers our own GDScript and skips `addons/`. It fails on any engine error or warning, on failing tests, and on tests that pass but leave orphaned nodes behind or make no assertions.

Tooling: GUT 9.7.1 lives in `addons/gut/`. `gdformat` and `gdlint` come from gdtoolkit, installed with `pipx install "gdtoolkit==4.*"` into `~/.local/bin`.

## Text content

- Player-facing text lives in plain text files in `assets/`, such as `assets/welcome.txt`, so it can be edited without touching code.
- Godot does not include `.txt` files in exported builds by default. When export presets are created, add `*.txt` to the non-resource export filter, or the text will be missing from release builds.

## Decisions

- Record every significant decision as a file in `docs/`, named `<topic>-decision.md`, with a status, a date and the reasoning.
- Read the existing decisions before proposing something that touches the same area.
- Decided so far: the engine (`docs/engine-decision.md`), map conversion (`docs/map-conversion-decision.md`) and map detection (`docs/map-detection-decision.md`), which is to try two approaches and compare them.
- Map conversion is a hard rule: no pixels from an uploaded image may end up in a level file, a thumbnail or anything shared. This applies to pre-made and user-made levels.

## Before committing

1. Run `tools/check.sh` and fix everything it reports until it passes with no errors and no warnings.
2. Commit `.import` and `.uid` files alongside the files they belong to. Never commit `.godot/`.
3. Commit to `main` and push.
