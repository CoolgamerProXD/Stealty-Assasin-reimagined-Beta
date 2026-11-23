# Assignment 007 implementation checkpoint — 2026-11-16

- Tuned the fictional Tung Chung campaign station's night fill and layered practical lights to retain cooler mood while lifting dark surfaces; added repeated platform-screen-door framing and restrained livery detailing to make the train/platform boundary more legible. Corrected the Meridian restaurant acceptance camera to look through its actual room opening rather than across the glazed service partition. Capture review showed an undersized/partly pinched dining portal, which is now widened at the screen returns; dining practicals and station fill are raised for scene readability.
- Stabilized staged characters in the capture fixture: NPCs stop at rest rather than frozen mid-stride, and the player is set to a standing idle for the actual scene view. The gameplay code and imported character assets are unchanged by this capture-only pose normalization.
- Run [45144819217](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45144819217) passed Windows export/smoke but failed five behavioral chair/checkpoint regressions after a dining-table relocation. The table was restored to its tested collision-aligned position; keep the wider portal without moving that furniture. Headless and visual review need a fresh rerun.

- Extended the genuine-scene capture harness to reopen/size-check the lossless PNGs, create native-resolution review JPEGs within a safe CI annotation payload budget, and write a JSON manifest. CI now validates every original/review file and exposes native-resolution review images separately from 320×180/160×90 summaries.
- Godot 4.4.1 run [45140609212](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45140609212) passed the full headless and Windows export/headless-smoke jobs, including all 18 capture and manifest checks. Its 3.3 MB full-resolution artifact is present, but the initial single-message review annotations were truncated at 4,096 characters. Follow-up run [45141607353](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45141607353) passed its per-image matrix, but API inspection found that only the first 10 chunks per check run were retained. The current transport uses <=29,900-byte images and <=4,000-character chunks (at most ten per image); it still needs a fresh CI run and reconstruction before review. Local Godot rendering, human visual review, playtesting, cultural review and target-device testing remain incomplete.

# Tung Chung story and presentation checkpoint

- Made the required courier and train-contact stages explicit, removed the resolved contact's blocking collision, kept the witness and intel optional, and added an extraction-to-debrief regression. The original user-reported failure's exact cause was not independently established; hidden guidance and contact collision were plausible contributors.
- Added a skippable courier escape, separate physical key pickup, walk-on platform, two connected fictional carriages, an exterior cinematic and final extraction. Checkpoints preserve or migrate the new states. Passengers and train remain procedural prototypes; exterior action is noninteractive.
- Added a compact Hong Kong intelligence tracker (Tab minimizes; O toggles optional details) and persistent Master, Music, SFX, Ambient and Dialogue bus controls. Existing generated effects and ambience are routed; there is no dedicated music or voiced dialogue asset.
- Run 43826351110 verified the code at `ddf4193`, including Windows export/headless smoke; interactive Windows testing, human audio/visual review and target-device benchmarking remain open. See TESTING.md.

# Full development sprint checkpoint

Added permanent, independently stored Initiation lesson coins, an equip/replenish loadout and throwable NPC distraction; three connected city neighbourhoods with walk-in rooms, upper-floor service disguises, local routines and optional lookout evidence; mission-specific witnesses, debrief outcomes and extraction presentation; local witness/guard reports; procedural character interaction and hit-response fixes; optional clue Instinct highlighting; quality-controlled practical lights, shadow and view-distance controls. These are still prototype implementations: the 15× destination, production animation/art, comprehensive combat/AI and human Windows/Iris Xe verification remain open. See TESTING.md for completed runs and WINDOWS_PLAYTEST_CHECKLIST.md for manual checks.

# Hong Kong campaign expansion — early playable slices

- Added five ordered Hong Kong operation scenes with separate physical key interactions, target and extraction gating, isolated checkpoints and persistent USB key tracking. A skippable secure-channel event follows final extraction; no file revelation is invented. Meridian stays optional.
- Added a fictional Tung Chung train carriage and contact, three city walk-in interiors, a mountain field archive and a traversable public monument approach. The city missions still reuse one blockout and are not the requested 15× expansion.
- Added role-aware trespass warning/grace/de-escalation and a non-graphic security alert pose, authored station navigation holes, brief entry cameras, procedural turn/weight blending, and integrated campaign tests. Health, advanced combat, comprehensive AI, production art and interactive hardware testing remain incomplete.

# Current iteration — prototype refinement

- Added nine CC0 Kenney furniture models, glazed hotel bays and restaurant screen, procedural floor finishes, new guest-room beds, and aligned dining chair collisions. Legacy checkpoints overlapping new furniture are relocated where possible.
- Added suite-local target and upper-gallery movement; separated station routes and added accelerated physical round-trip tests for all 16 station actors and four Meridian wing actors. Cross-floor pathfinding remains unimplemented.
- Added contextual synthetic ambient beds and surface-dependent steps, compacted selection and settings to fit 720p, populated the city with fictional parked traffic and skyline, and enlarged the purely scenic mountain landmark.
- Character primitives now share immutable meshes while retaining per-character materials and joint transforms; procedural running and crouching keep shoes near the floor. Quiet Line has a hand-held visual and brief use pose. No performance improvement on the target laptop is claimed without a measurement.
- Fixed the mountain terrain's collision winding after a physical traversal test exposed a blocked seam; added traversal checks on both terrain patches and preview routes, and prevented explicitly mismatched mission action IDs from completing objectives in checkpoint restores.
- Windows CI now launches the exported main menu, both missions and all three previews headlessly. This is not an interactive Windows playtest.

# Second pass — incremental prototype improvements

- Expanded original batched Meridian wing dressing, guest-room and suite details, and floor-local hotel routines. The public wing routes are on a dedicated ground-floor navigation region; there is no cross-floor NPC routing. Locke remains in the upstairs suite. Much of the decorative furniture remains non-colliding and the hotel is still a procedural prototype, not a finished luxury environment.
- Reworked the procedural figures into an upper-body group and hinged knees; crouching now lowers the torso and bends the legs instead of scaling the figure vertically. Steps use a synthesized transient synchronized to gait phase. This is not motion-captured or a production animation set.
- Added static facade/market and mountain-path detail, a few local visitors on open routes, and added collision to selected station columns and the information counter. The three locations remain independent exploration previews, not completed missions.
- Added automated local-route, crouch posture and staged capture coverage. Actual human playtesting and target-device measurement remain outstanding.

## 2026-11-16 — CC0 rig neutral pose correction
- Diagnosed the wide frozen poses as the imported CC0 bind pose: with zero procedural gait, the skeleton's hip-to-foot chains were still spread laterally. Build a model-specific neutral pose by aligning the leg chains down and relaxing the arm chains, then layer existing gait/gesture rotations over those corrections.
- Added a staged-pose regression check and re-captured the full 18-view suite. Godot 4.4.1 run [45153819125](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45153819125) passed 153 Assignment 006 checks, the full headless regression suite, and all 18 native-resolution capture jobs. Follow-up [run 45155176281](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45155176281) passed both Windows export/headless smoke and Linux headless regression, plus all 18 review jobs.
- The 1280×720 review JPEGs are in `screenshots/assignment007/review-run-45153819125/`. Manual review confirms the horizontal split poses are substantially reduced in facility and gameplay views; several fixtures remain awkwardly seated/hovering and the environments remain blockout-level. No human playtest, cultural review or target-device measurements are implied.

# Quality overhaul

- Added separately playable, labelled station, city and Ngong Ping exploration scenes to Mission Selection; Escape returns to the selector without changing campaign progression.
- Preserved the original Meridian and added a connected two-storey west wing, upper guest rooms and a stationary private-suite target. This is a procedural partial expansion, not a fully dressed production hotel; ground footprint ~3.5x, gross two-level surface ~7x.
- Added contextual HUD layout and original equipment icon, procedural document and terminal props, smoothed visual turning and gait-linked footsteps. Retained target terminal state, mission and save migrations. No health or radar was fabricated.

# Hong Kong direction checkpoint

- Preserved Initiation and legacy Meridian, including save paths; added locked planned chapter entries and an explicitly incomplete Tung Chung exploration preview.
- Added a fictional station blockout with a small scheduled crowd and two physical character concepts. No train encounter or campaign completion is claimed. Added station, city and respectful Ngong Ping map/target plans.
- Completed Meridian target state is now terminal, separate from temporary incapacitation, idempotent, and checkpointed with its visual outcome. Removed the experimental lobby reflection probe after a rendered lighting regression.

# Changelog

## Absolute Cinema iteration
- Added batched original hotel and annex dressing, practical lights and high-only fine detail.
- Added stance-derived sight rays, local disturbance discovery and simple scheduled activity gestures.
- Smoothed shoulder/FOV and weapon draw/aim/holster blending; added synthesized steps, ambience, UI and objective cues.
- Added shared Blackline UI styling, hit confirmation, smoother Ruby camera transitions, expanded rendered capture automation, and a Windows export/smoke job.
- HIGH uses FXAA and a single static lobby reflection probe; LOW omits the probe, practical lights and fine dressing.
- Remains a low-poly prototype; no claim of AAA art, a human playtest or target-laptop performance.


## Gameplay repair (2026-11)
- Briefing-known primary targets use a red no-depth-test mesh overlay; visible nearby relevant items remain yellow.
- A pulse on Adrian completes the primary objective; added simple hand-mounted sidearm poses and flash and more assessment-unit parts.
- Added persisted viewport quality presets and FPS toggle, compacted HUD, and automated rendered wall comparisons in CI.
- Production art, comprehensive preset scaling and physical-device playtesting remain outstanding.


## Target, aiming and Instinct update (unreleased)
- Add scheduled Meridian primary target Adrian Locke while retaining Ivo as witness, and migrate completed legacy checkpoints.
- Add RMB aim, center-ray LMB firing, collision impacts, audio/trace feedback and five-charge enforcement.
- Add Left Ctrl Instinct with discovered-target and nearby visible-item highlights, and a procedural Ruby exterior and character refinement. See testing notes for verification and limitations.

## Critical gameplay update (unreleased)
- Add live mission/equipment HUD, actual selected loadout, five-charge unsuppressed assessment pulses and non-graphic Quiet Line interaction; persist equipment in compatible checkpoints.
- Add Ivo Chen as the Meridian's physical witness objective; assessment unit now reacts to proximity. Preserve previously completed Meridian checkpoints.
- Add skippable 3D Ruby meeting with doors, moving actors, cameras, subtitles and synthesized tones; replace character capsules with original articulated low-poly figures and add basic environmental trim.
- These are still prototypes, not a production character/environment overhaul. See README for limitations and test scope.

## Campaign foundation (unreleased)
- Add original BLACKLINE/Ruby/Covenant campaign data, progression/unlock/replay and persistent settings, main menu, pause and results/debrief screen.
- Add Initiation greybox with two scheduled guards, moving assessment unit and three required records; reuse existing player, NPC, interaction and save systems, preserving the Meridian save path.
- Smooth crouch dimensions and camera pivot with a standing clearance check. Add campaign and mission runtime checks. Equipment is not usable; large requested systems and final production work remain incomplete (see README).

## 2026-11-15 — initial prototype

- Established Godot project, third-person player and primitive hotel greybox.
- Added configurable NPC profiles, schedules, navigation, local perception, memory and basic investigation.
- Added access rules, staff-role disguise, reusable interaction component, inventory, clue objectives and extraction.
- Added versioned save utility, headless test runner and development documentation. Runtime verification status is documented in TESTING.md.

## Continuation — 2026-11-15

- Added physical zone partitions, alternate doorway routes, tiled navigation and interaction line-of-sight checks.
- Connected versioned mission snapshots with validated restoration and previous-save backup to F5/F9.
- Expanded behavioral and data checks; Godot runtime verification remains pending.

## Audit and stabilisation — 2026-11-15

- Centralized and validated three-record / two-required mission data; aligned spawning, collection, HUD, extraction and save restoration.
- Prevented false repeat-extraction instructions and rejected invalid saved positions inside partitions.
- Expanded regression scenarios and reduced NPC memory-array churn. Godot runtime testing remains pending.

## Runtime regression — 2026-11-15

- Added official Godot 4.4.1 import, headless gameplay, virtual-display camera and timing checks to CI.
- Fixed expected malformed-save recovery emitting engine error logs; kept backup recovery behavior.
- Added schedule-recovery, interaction-input, camera and timing regression checks. Player, NPC and hotel presentation remain unchanged.
