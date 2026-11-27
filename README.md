# Roundabouts

*(working title)*

**A traffic light simulator in which you do your very best, and then a roundabout does it better.**

Roundabouts is a light-hearted indie puzzle/simulation game. You are handed a road junction, a box of traffic lights, a handful of sensors and a controller to program. Your job is to keep the traffic flowing. Your reward is a 15-second demonstration of how a roundabout would have handled it.

## The idea

1. **Pick a junction.** Play a built-in level, download one from the community, or make your own by uploading a screenshot of any real junction: the one outside your house, the one that ruins your commute, the one your town is famous for.
2. **Place your hardware.** Position traffic lights, pedestrian crossings and sensors wherever you think they belong.
3. **Program the lights.** Set the phases, timings and rules that decide who goes when.
4. **Run the simulation.** Traffic arrives. Things go well, or they don't.
5. **Get your score.** Then watch the roundabout.

## Features

### Any junction can be a level

Upload a screenshot of a road junction and the game turns it into a playable level. Roads, lanes and entry/exit points are detected from the image, and you can correct anything the game gets wrong in the level editor before you play or share it.

The screenshot is only an input. Every junction is redrawn entirely in the game's own art style, and nothing of the original image is kept. This is true of the built-in levels and of every level made by players. See [docs/map-conversion-decision.md](docs/map-conversion-decision.md).

### Lights and sensors

A toolbox that grows as you progress:

- **Traffic lights**: standard signals, filter arrows, pedestrian crossings
- **Induction loops**: detect vehicles waiting at or approaching a stop line
- **Queue sensors**: measure how far back the traffic has built up
- **Pedestrian buttons**: which pedestrians will press repeatedly, as is tradition
- **Timers and clocks**: for behaviour that changes at rush hour

Every piece of kit costs money, and each level has a budget. Covering the junction in sensors is a valid strategy only if you can afford it.

### Program the junction

Lights do nothing until you tell them what to do. Programming ranges from simple to deep:

- **Fixed timing**: green for 20 seconds, then swap. A classic. Rarely good.
- **Sensor-driven rules**: "if the queue on the north approach reaches the sensor, extend green by 10 seconds."
- **Full phase logic**: design your own stages, priorities and fallbacks for the junctions that really deserve it.

### Simulated traffic

Each level has its own traffic pattern: a quiet morning, the school run, a football match letting out. Vehicles behave like vehicles, which is to say imperfectly. Expect:

- Drivers who don't notice the light has changed
- Buses that need a lot of room
- Cyclists, pedestrians and the occasional learner driver
- Emergency vehicles that need to get through *now*

### Scoring

You are judged on the things real traffic engineers are judged on, plus a few they aren't:

- Average and worst-case waiting time
- Vehicles through the junction
- Collisions (ideally zero)
- Pedestrians kept waiting in the rain
- Money spent
- Horn usage

### The roundabout wrap-up

At the end of every level, a roundabout is superimposed over your junction and the same traffic is replayed through it for 15 seconds.

It is not passive. **You control it.** Speed it up, slow it down, drop extra traffic on it, try to make it fail. It will be fine. It is a roundabout.

Your score is then shown alongside the roundabout's score. This is not to make you feel bad. It is to prove a point.

## Tone

Roundabouts is a proper simulation with a silly heart. The traffic model is real enough that clever solutions genuinely work, and the game never takes itself seriously while showing you that. Dry humour, passive-aggressive council memos, and an unshakeable editorial position on circular junctions.

## Sharing levels

Levels built from your own screenshots can be shared with other players, along with leaderboards per junction, so you can find out whether anyone on Earth can make your local crossroads work.

## Platforms

- **Steam** is the primary target, with **Steam Workshop** used for sharing community-made levels.
- **Epic Games Store** and other storefronts are under consideration.
- Desktop first: Windows, macOS and Linux.

## Technology

Built with [Godot 4](https://godotengine.org/), developed on macOS, with Steam integration through GodotSteam. The reasoning is in [docs/engine-decision.md](docs/engine-decision.md).

### Getting started

1. Install Godot 4 (standard build, not .NET).
2. Open Godot, choose **Import**, and select `project.godot` in this folder.
3. Press **F5** (or **Cmd+B** on macOS) to run.

Conventions, folder layout and commands for contributors are in [CLAUDE.md](CLAUDE.md).

## Status

Early concept. Nothing is playable yet.

### Rough roadmap

- [ ] Core traffic simulation on a hand-built test junction
- [ ] Placing lights and sensors
- [ ] Light programming interface
- [ ] Scoring
- [ ] The roundabout wrap-up
- [ ] Screenshot-to-level import and level editor
- [ ] Campaign levels
- [ ] Level sharing and leaderboards
- [ ] Steam release

### Open questions

- **Screenshot-to-level detection**: how the road layout is read from an image is not yet chosen, and is the riskiest feature in the game.
- **Left- or right-hand traffic**: both, presumably, chosen per level.
- **The name**: "Roundabouts" gives away the ending. This may be a feature.

## Licence

To be decided.
