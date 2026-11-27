# Engine decision

**Status:** decided, 27 November 2026
**Decision:** Godot 4

## What the engine needs to do

| Requirement | Why it matters |
| --- | --- |
| Develop on macOS | The Mac is the main development machine. A PC is available but not preferred. |
| Ship to Windows | Most Steam players are on Windows, so the Windows build is the one that matters most. |
| Steamworks and Steam Workshop | Needed for the store release and for sharing community-made levels. |
| Strong 2D, top-down | The game is a 2D view of a junction. No 3D is needed. |
| Heavy in-game UI | The light-programming interface and level editor are a large part of the game. |
| Load images at runtime | Players upload screenshots that become levels. |
| Hundreds of simulated agents | Vehicles, cyclists and pedestrians, ideally in a deterministic simulation so the roundabout replay uses the same traffic. |
| Low cost and low risk | Indie budget, with no surprises in licensing. |
| Other stores possible | Epic Games Store and others are under consideration. |

## Summary

| Engine | Mac development | Windows build from the Mac | 2D | In-game UI | Steam Workshop | Cost |
| --- | --- | --- | --- | --- | --- | --- |
| **Godot 4** | Very good | Yes | Very good | Very good | Community plugin (GodotSteam) | Free, MIT licence |
| **Unity** | Good | Yes, with a limitation | Good | Good | Mature libraries | Free below a revenue threshold |
| **Web stack (TypeScript, PixiJS, Electron)** | Very good | Yes | Good | Excellent | Community library | Free |
| **GameMaker** | Good | No, needs the PC | Very good | Weak | Official extension | One-off commercial licence |
| **Bevy (Rust)** | Good | Possible, fiddly | Good | Weak | Community crate | Free |

## The options

### 1. Godot 4 (recommended)

Open-source engine with a dedicated 2D renderer and a full editor that runs natively on Apple silicon.

**Pros**

- Free under the MIT licence: no royalties, no revenue thresholds, no licence terms that can change later.
- The Mac is a first-class development platform, and Windows, macOS and Linux builds are all exported from the Mac.
- True 2D engine with pixel coordinates, rather than 2D layered on a 3D engine.
- Its UI system is strong enough that the Godot editor is built with it. That suits the programming interface and level editor.
- GodotSteam covers Steamworks including Workshop, and is used by many shipped Steam games.
- Lightweight: the editor opens in seconds and iteration is fast.
- Text-based scene and resource files work well with git.

**Cons**

- Steam and Epic integrations are community-maintained rather than official.
- Smaller asset store and fewer ready-made solutions than Unity.
- No built-in computer vision. The screenshot-to-level feature needs a native extension, a C# library or an external service.
- GDScript is slower than C#. If the simulation gets large, the hot loop may need moving to C# or C++.
- Console ports go through third-party porting companies, should that ever matter.

### 2. Unity

The most widely used indie engine, programmed in C#.

**Pros**

- Largest ecosystem: tutorials, assets, plugins and hireable expertise.
- Mature Steamworks libraries (Steamworks.NET, Facepunch.Steamworks) with full Workshop support.
- C# is fast and well suited to a large simulation. The Burst compiler and job system are available if the vehicle count becomes extreme.
- Paid OpenCV integrations and built-in neural network inference would help with screenshot-to-level.
- The clearest path to consoles and mobile.

**Cons**

- Heavy for a 2D game: slow editor, long import times and large builds.
- Windows builds from the Mac only work with the Mono scripting backend. The faster IL2CPP backend requires building on Windows.
- The 2023 runtime fee announcement, later withdrawn, damaged trust in Unity's licensing. Terms could change again.
- Free only below a revenue and funding threshold, then a per-seat subscription.
- Two overlapping UI systems, neither as pleasant as Godot's for tool-like interfaces.
- Binary-heavy project files are harder to manage in git.

### 3. Web stack: TypeScript, PixiJS and Electron

Build the game as a web application and wrap it as a desktop app for Steam.

**Pros**

- HTML and CSS are the best UI technology of any option here, which suits the programming interface and level editor.
- Image upload and processing is easy. OpenCV.js and browser-based machine learning libraries run directly.
- Identical development experience on Mac and PC, with instant hot reload.
- A playable demo can go on itch.io or a website with no install, which is useful for marketing a comedy game.
- Successful Steam games have shipped this way.

**Cons**

- No editor. Scenes, tooling and the game loop are all built by hand.
- Steam integration relies on smaller community libraries, and the Steam overlay is known to be awkward with Electron.
- Lower performance ceiling than a native engine for a large simulation.
- Larger downloads and memory use, since each copy bundles a browser.
- Assembling audio, input, save games and packaging is more work than in an engine.

### 4. GameMaker

Long-established 2D engine behind many indie hits.

**Pros**

- Built specifically for 2D, and quick to get something moving on screen.
- Official Steamworks extension that includes Workshop support.
- Runs on the Mac.
- Proven track record of commercial 2D releases.
- Low one-off cost for a commercial licence.

**Cons**

- Windows builds have to be made on Windows, so the PC becomes part of the regular workflow.
- Weak support for complex UI. The programming interface and level editor would be largely hand-built.
- Its own language, GML, has limited structure for a large simulation codebase and skills do not transfer.
- Closed source and proprietary.

### 5. Bevy (Rust)

Open-source, code-only engine built around an entity component system.

**Pros**

- The entity component system is a natural fit for simulating many vehicles, and performance is excellent.
- Rust makes a deterministic simulation easier to get right.
- Free and open source under MIT and Apache licences.
- Rust's image-processing libraries would help with screenshot-to-level.

**Cons**

- No editor. Everything is code.
- Still pre-1.0, with breaking changes between releases.
- UI is its weakest area, and UI is a large part of this game.
- Steep learning curve and slower iteration because of compile times.
- Cross-compiling to Windows from the Mac is possible but needs extra setup.
- Small ecosystem and few shipped commercial games to learn from.

## Not shortlisted

**Unreal Engine** was left out. It is built for 3D, its 2D support is minimal, the editor is heavy, and macOS is a second-class development platform. Its link to the Epic Games Store is not a reason to choose it: any engine can publish there.

## Recommendation

**Godot 4.** It is the only option that is strong on all of the things this game leans on hardest: Mac-first development, exporting the Windows build from the Mac, real 2D, and a capable UI system. It is free with no licensing risk, and GodotSteam covers Workshop.

Suggested approach:

- Start in GDScript for speed of iteration. Move the simulation core to C# or C++ only if profiling shows it is needed.
- Treat screenshot-to-level as a separate problem with its own decision. It is the riskiest feature under every engine, and it should be prototyped early.
- Keep the simulation logic separate from rendering so that it is deterministic and testable.

**Runner-up:** the web stack. It would be the better choice if the game turns out to be mostly interface with a small simulation view, or if a no-install browser demo becomes central to marketing.

## The PC is still needed

Whichever engine is chosen, the Windows build must be tested on real Windows hardware before release. With Godot the PC is a test machine used occasionally, rather than a development machine.

## Caveats

- Licensing and pricing details were written from general knowledge in November 2026 and were not checked against the vendors' current terms. Verify before committing to a paid option.
- Publishing a macOS build on Steam requires a paid Apple Developer account for signing and notarisation, under every option.
