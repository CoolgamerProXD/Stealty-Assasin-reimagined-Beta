# Assignment 007 in-progress note

The current active branch adds Tung Chung station/train visual details and improves the review evidence path for the 18-scene automated capture suite. Run `tests/assignment006_visual_acceptance.gd` through the pinned Godot 4.4.1 Xvfb command in `.github/workflows/godot-regression.yml`; examine original PNGs as well as native-resolution review JPEGs. The 320×180 and 160×90 images are previews only. Local Godot execution and human review remain outstanding; do not infer visual acceptance from static parsing or manifest checks.

# Second-pass development notes

Preserve the existing mission/save contract and keep new routes within their dedicated floor-local navigation regions. `EnvironmentDressing` and preview `DistrictDetails` batch colorized decorative geometry; do not assume that a visible prop has collision. The stance rig uses torso translation and knee joints driven by the current physical stance, with footsteps derived from the same gait phase. Synthetic CI capture scenes use staged cameras; overhead plans deliberately hide roof/slab visuals. Run the full Godot suite and Windows export when changing these systems, and playtest on actual target hardware before making quality or performance claims.

# Quality-overhaul checkpoint

Run the three previews from Mission Selection. The city and mountain previews are rough static procedural environments without populations; the station retains its agents. Meridian keeps original coordinates and adds a two-floor extension. New architectural detail still needs art, collision, accessibility, navigation and target-device performance review. The ground footprint is ~3.5x the original; combined gross floor area ~7x.

# Development status

The station blockout can be run via `scenes/tung_chung_preview.tscn` or the explicitly labelled main-menu preview. It has no campaign mission logic, combat, Instinct, pause/settings, checkpoints or train gameplay. Architectural props and the decorative escalator are not collidable or traversable; the navigation mesh is an open rectangle, so NPCs may walk through scenery. See HONG_KONG_MAP_PLAN.md for planned work before enabling the real mission.

The current work preserves the navigation and collision layout and batches optional architectural dressing into MultiMeshes. The Windows export preset can be used with official 4.4.1 templates; the opt-in CI Windows job performs only a headless launch. The current build also includes CC0 Kenney furniture; see THIRD_PARTY_ASSETS.md. Keep objective/save migrations backward-compatible and verify scene/render behavior in addition to parsing.


## Campaign expansion status
The entry scene is now the main menu. To develop the two greyboxes directly, run `scenes/initiation.tscn` or `scenes/hotel.tscn`; campaign completion transitions and pause integration are enabled when the campaign launches them. The existing player and NPC capsule models and spring-arm controller are retained. Crouch modifies their dimensions/eye pivot, not the basic controller. The additional content is an incremental foundation; see README for missing deliverables.

## First session — 2026-11-15

The workspace was an empty repository except for a README. This session adds a Godot project and an initial hotel prototype. Checkpoints A–D are **partial**; E is a primitive greybox; F has not been completed. See TESTING.md for verification status.

Implemented in code, pending Godot runtime verification: third-person capsule movement and spring-arm camera; simple partitioned hotel floor with public/staff/secure positional zones; three data-driven scheduled NPCs using navigation agents; throttled visual trespass detection, local memory, suspicion, investigation and routine recovery; a uniform that grants staff access; record interactions, inventory and extraction; HUD; versioned mission snapshot and backup save helper; behavioral test runner.

Historical early-prototype note (superseded where it conflicts with README and the current audit): the hotel is a simple partitioned greybox rather than furnished rooms; furniture lacks collision and the navigation mesh is manually tiled, not baked. No operable doors, animations, sound, genuine conversations, simulation LOD, settings persistence, difficulty or graphics presets. Saves currently omit NPC state and are not crash-durability tested. Only alertness and curiosity influence the current NPC logic; other personality properties are reserved. The disguise resource is not yet consumed. There is no separate area alert, information sharing, configurable mission graph, failure condition or persistence of NPC state. The awareness HUD shows the maximum NPC value as debug feedback. Crouch changes speed, not capsule height or visibility. NPC category currently affects appearance, not decision policy. The staff uniform is an unrestricted marker, not a full disguise interaction. These are explicit prototype compromises, not completed systems.

Next: run and fix headless tests on a real Godot build; playtest in editor on Windows; replace the primitive layout with authored interconnected rooms and baked navigation; add real interactions; improve schedule interruption, roles and per-NPC feedback; expand persistence; then measure and optimize on target hardware.

## Continuation — 2026-11-15

Added two physical partitions with alternate openings, a corresponding hand-authored navigation grid and line-of-sight checks for interaction selection. Added F5/F9 mission snapshots with validation and a previous-save backup. Expanded planned Godot tests for real navigation, physics occlusion, interaction reachability and save recovery. These changes remain pending Godot runtime verification. The source build was restarted outside the repository.

## Audit and stabilisation — 2026-11-15

Moved the three record definitions and unchanged two-record requirement into one validated mission configuration. The HUD now separates collected, available and required counts; extraction gives an accurate already-completed message. Collection and restoration check the same IDs and inventory capacity. Invalid configurations fail closed, and saved player positions inside partitions are rejected. NPC memory expiry no longer allocates a filtered array every physics tick. Expanded headless tests are present but not runtime-verified; see AUDIT.md and TESTING.md.

## Runtime regression — 2026-11-15

Official Godot 4.4.1 CI run 43699069502 passed 63 headless behavioral checks and five automated camera checks on Xvfb. A corrupt-save log-spam defect was fixed without changing player, NPC, camera, scene or hotel files. A human Windows playtest and target performance measurements remain outstanding; see TESTING.md and PERFORMANCE.md. Earlier session entries are historical.
