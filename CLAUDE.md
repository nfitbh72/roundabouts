# Working on Roundabouts

## How to work with me

- Suggest improvements regularly. Don't simply wait for instruction.
- Humour is important in this game, so add humour to our conversation. Douglas Adams is my favourite author, so the occasional quote or joke in that style is welcome.

## Rules

- Keep the project root with as few files as possible. Everything should be well structured in folders.
- Tidy code is very important to me. This codebase is likely to evolve a lot, so it needs to be very maintainable.
- Game logic and display must be kept separate at all times. Game logic should use pure functions wherever possible.
- For now, commit directly to `main` and push. We will set up agentic workflows and a proper PR process later.

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
| `addons/` | Third-party Godot plugins, such as GUT and GodotSteam. |
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
| Check the project loads | `godot --headless --import && godot --headless --quit-after 60` |
| Run the tests | `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` |
| Format | `gdformat simulation display tests` |
| Lint | `gdlint simulation display tests` |

GUT and gdtoolkit (which provides `gdformat` and `gdlint`) are not installed yet.

## Decisions

- Record every significant decision as a file in `docs/`, named `<topic>-decision.md`, with a status, a date and the reasoning.
- Read the existing decisions before proposing something that touches the same area.
- Decided so far: the engine (`docs/engine-decision.md`) and map conversion (`docs/map-conversion-decision.md`).
- Map conversion is a hard rule: no pixels from an uploaded image may end up in a level file, a thumbnail or anything shared. This applies to pre-made and user-made levels.

## Before committing

1. Format and lint.
2. Run the tests.
3. Check the project loads headlessly with no errors or warnings.
4. Commit `.import` and `.uid` files alongside the files they belong to. Never commit `.godot/`.
5. Commit to `main` and push.
