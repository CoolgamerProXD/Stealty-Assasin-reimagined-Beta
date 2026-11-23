# PROJECT ASSASSIN — Technical Handoff and Recovery Audit

## Assignment 007 — implementation in progress (INCOMPLETE)

The active branch is `arena/9199c996-stealty-assasin-reimagined-bet`; current baseline at continuation was `b574488`. This iteration adjusts Tung Chung campaign station illumination and train/platform details, fixes the Meridian restaurant capture angle, and adds native-resolution review JPEGs plus a machine-readable image manifest to the existing 18-view acceptance harness and CI checks. No Godot runtime/export/capture was completed locally; the earlier GitHub release-asset download failed. Verify with a fresh headless and opt-in `[windows]` CI run, inspect the genuine full-resolution captures, and preserve the human visual, continuous playtest, cultural review, and Windows/Iris Xe requirements as outstanding until performed.

## Assignment 006 — finish campaign-wide visual transformation (INCOMPLETE)

**Current checkout:** branch `arena/9199c996-stealty-assasin-reimagined-bet`, based on `c5c9f11d9079ba9c906c520ce25227ffd8476fe7`. Assignment 005 was explicitly incomplete; previous Assignment 004 acceptance is not Assignment 006 completion.

- Eight MakeHuman/MPFB-derived CC0 character GLBs are in `assets/characters/makehuman_cc0/`, pinned to RUBBERNECK source commit `7c331e647229364f3160790fe158beedf132075a`. `tools/prepare_cc0_characters.sh` and `tools/convert_makehuman_glb.js` reproduce the Meshopt/quantization decode, MikkTSpace tangent generation, WebP-to-PNG conversion, and alpha-mask setup. glTF-Validator 2.0.0-dev.3.10 reports zero errors and warnings for all eight models.
- `StylizedPerson` loads skinned CC0 scenes for player/NPC/cinematic/passenger actors, selects models by appearance/outfit, tints garment materials, attaches equipment to imported wrists and drives skeleton motion from existing movement/gesture state. Outfit acquisition changes the model and taken NPCs retain singlet/boxer coverage. Godot 4.4.1 import, Windows export/headless smoke, behavior, disguise and multi-level facility checks passed in CI run [44518105768](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44518105768). These checks do not establish human visual fit, animation/material quality, cultural review or interactive Windows performance. The local sandbox has no Godot executable.
- Follow-up: run [44519637253](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44519637253) exposed a frame-duration-sensitive Instinct easing assertion; a deterministic 60 Hz test fix followed. Run [44520371269](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44520371269) hit the existing Godot 4.4.1 render-thread `finalize` import diagnostic before tests. Run [44520489133](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44520489133) passed import and earlier runtime suites but failed the new visual capture step. Direct diagnostics in [44521725323](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44521725323) identified two fixture defects (wrong vendor actor selection and attempting to close an already-discovered, one-way door); both were corrected. Latest [run 44522902577](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44522902577) passed both jobs; capture suite passed 25 checks, 0 failures and asserted 18 1280×720 views. Full PNGs and thumbnails are in artifact `14528687993`. Downloading from the sandbox failed with `EOF`, so the images are not locally reviewed. The fixture isolates campaign persistence to a unique scratch save and restores settings/progress after capture.
- Partial prior CI thumbnails are under `screenshots/assignment006/ci/`; inspection shows simple stylized/blockout environments, not accepted polished art. No equivalent-condition before/after set, complete human visual review, continuous interactive playtest, cultural review, or Windows 11 / Intel Iris Xe target measurement exists. Assignment 006 remains incomplete: continue implementation/testing on this active branch, report every gate truthfully, then commit/push the final verified updates and clean the worktree.

## Assignment 004 — Hong Kong sandbox rebuild (automated checks passed; visual/playtest sign-off outstanding)

**Status date:** 2026-11-16 UTC  ·  **Branch:** `arena/9199c996-stealty-assasin-reimagined-bet`  ·  **Verified implementation commit:** `b98e15a` (CI run 43963744666).

This records what automated tests and preview review establish; it is not a claim of full visual or interactive-playtest sign-off. Earlier sections document prior assignments and must not be interpreted as additional Assignment 004 verification.

- The selectable campaign presents one `hong_kong_sandbox` between Tung Chung and Ngong Ping; Streets, District and Harbour are not selectable duplicates. The integrated sandbox scene composes a market, commercial district and harbour, including an approximately 16 m corporate tower with five floor plates, furnished interiors, floor-local navigation and breakable glazing.
- `tests/hong_kong_campaign_test.gd` passed **30 integrated campaign checks, 0 failures**. CI also passed the general behavioral suite (**256 checks, 0 failures**), lesson coin progression (**31, 0 failures**), and Hong Kong environmental/capture checks (**17, 0 failures**). The coverage includes sandbox campaign/key/target state, migration, target completion vs temporary incapacitation, required physical keys and extraction gating. This is automated harness evidence, not a human route-completion report.
- Pinned Godot **4.4.1** run [43963744666](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43963744666) passed both jobs on `b98e15a`: project import and main-scene startup; general, integrated-campaign, coin, NPC route, camera, wall-render and Hong Kong staged-entry/environment checks; plus all preview steps. The Windows job verified the official engine/template hashes, imported/exported the Windows release build, and launched all **10 configured scenes** headlessly, including `mission_hong_kong_sandbox`, without logged errors. This is a Windows CI export/smoke test, not a Windows human playthrough or a test on Windows/Iris Xe target hardware.
- The Windows job is conditional on the pushed head commit message containing `[windows]`. Run [43961966391](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43961966391) had no such suffix and therefore skipped Windows; the later tagged workflow commits ran Windows successfully. The preview-ordering/source commit `b98e15a` passed both jobs and all Assignment 004 preview steps in [43963744666](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43963744666). The subsequent documentation/capture commit `9e57f33` passed its full headless run [43964696401](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43964696401); Windows was skipped on that docs-only commit because it lacked the opt-in suffix. Windows export/smoke verification remains green for the unchanged game sources from `b98e15a`.
- Nine 320×180 preview JPEGs from the final run's check annotations are saved under `screenshots/assignment004/`: market and commercial districts, tower lobby/interior, all three target/Instinct views, local awareness, and completed-objective HUD. They are CI-generated previews rather than full-resolution captures. Review confirmed the subjects/UI rendered, but the images show simple, muted procedural low-poly scenery with sparse environmental detail; HUD text is small at this size. Treat visual polish as **not signed off** and inspect full-resolution output before claiming final art quality. No interactive human playtest is recorded.
- `CampaignProgress` handles multi-key missions and explicit retained legacy keys. Legacy city mission completion does not become sandbox target completion; old standalone checkpoint files are left untouched but are not resumable from the new menu, and old single-target booleans are ignored by the sandbox checkpoint loader. This migration behavior is covered by the automated campaign test; disclose the checkpoint limitation. Initiation/Meridian, Tung Chung/Ngong Ping, settings, lesson records/coins and explicitly stored recovered keys remain covered by existing campaign/progression checks.
- New Assignment 004 geometry/material/runtime assets are authored in GDScript; no new third-party asset is added. Existing nine Kenney Furniture Kit models are CC0 and documented in `THIRD_PARTY_ASSETS.md` and `assets/kenney_furniture/PROVENANCE.md`. District/building designs are fictional, not traced from real tactical layouts. Ngong Ping and the public Tian Tan Buddha builder remain; the fictional field office is separate from the monument.
- Local checks before the last workflow-only edits: Python `unittest` **9/9 passed**, campaign JSON parsed, and `git diff --check` passed. The latest CI reran its data checks after those workflow edits. No target-hardware benchmark or human interactive playthrough has been conducted; report automated evidence separately.
- **Remaining sign-off:** review improved/full-resolution visuals and HUD readability, conduct and record an interactive playthrough if available, and test target hardware before making any performance claims. Do not describe the automated CI capture preview as a polished-art or human-playtest result.

## Assignment 003 progress — 2026-11-16 (active branch)

## Assignment 003 progress — 2026-11-16 (active branch)

This is the latest status note and supersedes the Assignment 002 “current working tree” wording below for the Assignment 003 implementation. The checkout and remote were verified before changes: `CoolgamerProXD/Stealty-Assasin-reimagined-Beta`, branch `arena/9199c996-stealty-assasin-reimagined-bet`, baseline `aea3ad8e16e323967d33bf7ecf05b72b367b6a80`.

- Mission target status now distinguishes temporary target incapacitation from permanent objective completion. The Quiet Line updates only the temporary status for the Meridian primary; recovery clears it, it cannot unlock extraction, and Mission HUD text explicitly states it is not complete. Checkpoints record the temporary status and remaining stun duration, and restore it without converting it to permanent completion. The assessment pulse/tag and target conversation remain permanent completion paths with existing idempotence; ordinary bystanders remain separate.
- Tung Chung’s train now has a physical luggage trolley with a route split and readable “pass either side” signage. The courier starts moving only after the player crosses the first-car trigger, traverses into the forward car using collision-aware CharacterBody motion, and stops for a playable catch/confrontation. The player is never moved by the chase; seat rows around the trolley were adjusted to keep both sidesteps navigable. Checkpoints preserve the courier position and chase flags. The existing five-key, mission order, physical pickup and extraction rules are unchanged.
- Automated coverage was added for non-completing temporary target status, recovery, checkpoint restoration, collidable route obstacle, actual player movement through the chase, and chase checkpoint restoration. Existing five-key/campaign/HK cases remain in place.
- Checks completed: local Python data unit tests **8/8 passed** and `git diff --check` passed. Full pinned Godot 4.4.1 workflow [43859935139](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43859935139) passed on `42f528a`: project import/startup, **256** general checks, **179** integrated Hong Kong checks (including the trolley route, moving courier, and chase checkpoint), **31** coin checks, **20** NPC soak checks, **24** camera checks, **15** wall-render checks, **28** HK visual/capture checks, and remaining cinematic/capture steps. No `SCRIPT ERROR`, `ERROR`, or test failures were reported.
- The same run’s Windows job passed official Godot/template verification, import, Windows release export, and headless smoke launches for all **12 configured scenes**. This is a Windows CI export-and-smoke check, not a human Windows playthrough or a measurement on target Windows/Iris Xe hardware.
- The CI virtual-renderer sample reported Tung Chung 30-frame averages of **27.27 FPS LOW, 10.67 MEDIUM, 8.73 HIGH** (the workflow’s software-rendered capture environment). Those are only brief automated Linux/Xvfb measurements—not target-device performance or interactive gameplay benchmarks. CI generated capture previews, but this pass does not claim full-resolution visual sign-off or direct human review of the pursuit scene.
- **Still unverified:** interactive human route completion, both route choices on actual hardware, full-resolution visual review, and Windows 11 / Iris Xe performance. Do not treat automated travel/checkpoint tests or software-rendered frame samples as those results. A local Godot executable was unavailable; the CI workflow provided the Godot behavioral and export validation.
- Commit `42f528abfaafbdf163e0389debbc52622e7a54e2` was pushed to the active assignment branch; this section records its CI results. Keep all further work on this branch and leave the tree clean.

**Audit date:** 2026-11-16 (UTC)
**Audited checkout:** `CoolgamerProXD/Stealty-Assasin-reimagined-Beta` (the repository actually configured as `origin` in this checkout)
**Branch:** `arena/9199c996-stealty-assasin-reimagined-bet`
**Exact starting HEAD:** `c5c9f11d9079ba9c906c520ce25227ffd8476fe7`
**HEAD subject:** `Document Tung Chung verification and remaining limitations [skip ci]`
**Declared parent:** `ddf41938ef1934a3cc26a2d9cdf7c25473fe6ee3` (the parent object is not present in this shallow local clone)
**Working tree at start:** clean. No gameplay/source files were changed during this audit.

## Assignment 002 progress — 2026-11-16 (current working tree)

This dated update records Assignment 002 implementation on the same branch; it supersedes older “next work” statements below only where the work has since been attempted. The original audit remains historical context. Work prioritizes Tung Chung and reusable station materials rather than starting a new game or completing all five Hong Kong operations.

- Added seven original, deterministic, seamless 256×256 albedo maps via `tools/generate_tung_chung_textures.py`; filenames, regeneration and authorship are recorded in `assets/procedural/PROVENANCE.md` and `ASSETS.md`. The procedural station-material helper and Tung Chung dressing use cached materials. `VISUAL_DIRECTION.md` records the broad user-reference goals without copying their subjects/assets.
- Expanded the Tung Chung carriage with window glass, collision-preserving wall shells, trim, route/interior details and four distinct procedural seated passengers. Added a separate, fictional, noninteractive exterior departure cutaway on first physical boarding; Escape and natural completion converge on restored train control, and a persisted flag prevents replay. Existing physical key award remains separate from target completion. Older aboard checkpoints migrate to an already-seen departure state.
- Added and executed campaign/capture assertions for carriage windows, seated poses, one-time departure, Escape skip, key/save state and camera activation. Latest Godot suite passes; these are automated synthetic scene tests and staged captures, not a human route/playthrough.
- Checks completed locally before the latest visual polish: `gdparse` accepted all six changed GDScript/test scripts (parser only); Python unit tests passed **8/8**; Python generator compilation passed; repeated texture generation produced identical hashes; all seven PNGs were byte-checked for exact wrap edges; `git diff --check` passed.
- GitHub Actions [43856230080](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43856230080) on `bfc94ac` passed the full Godot 4.4.1 workflow: project import, main-scene startup, 250 general checks, **176 Hong Kong campaign checks (0 failures)**, coin progression, NPC route soak, virtual-display/camera checks, image regressions, cinematic captures, and **28 Hong Kong capture checks (0 failures)**. This verifies scripted transitions and capture execution in CI, not target-device performance. Earlier failed runs `43850856361`, `43851044446`, and `43851525058` caught/resolved a typing issue and test-query/boarding-test issues; later passing runs supersede them.
- The latest CI train and departure thumbnails were decoded from check annotations and visually inspected at **320×180**. The cabin now has a readable aisle and warmer cabin lighting; the departure cutaway shows the train profile and city lights through its window bays. This is limited thumbnail review, not full-resolution art sign-off. Full-resolution artifact download was blocked by the sandbox's artifact-host network restriction.
- Latest automated fixed-view CI samples on Linux Xvfb/Mesa software rendering (30 frames per preset) reported Tung Chung LOW **39.06 FPS**, MEDIUM **13.19 FPS**, HIGH **11.36 FPS**; District LOW **64.28**, MEDIUM **19.59**, HIGH **18.32**; Ngong Ping LOW **55.76**, MEDIUM **19.38**, HIGH **19.30**. These are short virtual-renderer samples, not Windows 11 / Iris Xe performance or an interactive/full-route benchmark.
- **Still outstanding:** human playthrough, full-resolution visual review of station/train/cutaway, collision/window openings and passenger appearance in an interactive viewer, actual Windows export/playtest, and target Windows 11 / Intel Iris Xe performance. No human completion, full-resolution visual sign-off, or target hardware numbers are claimed.
- Next: inspect the CI captures on a renderer-capable workstation; exercise the full Tung Chung route without and with cinematic skips and across current/legacy checkpoints; and record actual device measurements separately. Preserve Initiation/Meridian, campaign progression, physical-key/checkpoint separation, Low/Medium/High and FPS controls.

The implementation and verification notes are committed and pushed to the current branch; latest tested gameplay code is `bfc94ac`. Do not interpret automated CI captures as human playtesting or hardware performance evidence.

> The request named `Stealty-Assasin-redesigned-computing-machine-Beta`, while the supplied checkout's `origin` is `Stealty-Assasin-reimagined-Beta`. The present checkout, Git remote configuration, and verified CI run URL belong to the latter. This handoff describes the checkout actually audited, not an uninspected repository inferred from the request URL.

## How to use this document

This is a verified source-level map of the project at the starting commit, not a promise that every feature has received human playtesting. Statements marked **automated** are supported by tests/CI; statements marked **not tested interactively** require a human to verify. Existing detailed notes remain useful: `README.md`, `ARCHITECTURE.md`, `GAMEPLAY.md`, `ASSETS.md`, `AUDIT.md`, `TESTING.md`, `DEVELOPMENT.md`, `NPC_AI.md`, `PERFORMANCE.md`, `HONG_KONG_MAP_PLAN.md`, `THIRD_PARTY_ASSETS.md`, `UI_REFERENCES.md`, `WINDOWS_PLAYTEST_CHECKLIST.md`, and `CHANGELOG.md`. Where older portions of those files conflict, prefer current source/configuration and the latest dated section of each file.

## Audit scope and checkout facts

- One checked-out commit is visible to `git log` (`c5c9f11`, marked `grafted`); earlier history is shallow/unavailable locally. The commit object records parent `ddf4193…`, but that object cannot be resolved in this clone. Do not treat this one-entry local log as the full project history.
- Godot project configuration: Godot 4 project format 5; feature compatibility declares **4.4** and Compatibility renderer. Existing documentation and CI pin **Godot 4.4.1**.
- Main scene: `res://scenes/main_menu.tscn`.
- One autoload: `Campaign` → `res://scripts/core/campaign_state.gd`.
- Tracked project at this HEAD: 101 files in the initial commit snapshot; 14 `.tscn` scenes, 41 production GDScript files, 8 GDScript test scripts, one Python test module, five JSON data files, two shaders and nine imported Kenney GLBs. There are 15 pre-existing Markdown documents repository-wide (14 at root plus the asset provenance file); adding this handoff makes 16.
- A source scan found **no checked-in `uid://` identifiers** in scenes/scripts/config. Godot may create import metadata/UID mappings in its ignored `.godot/` editor cache after import; no such generated ID is claimed here.
- No standalone image/texture, audio recording, font, `.tres`/`.res` or animation resource files were found. Most visuals, materials, poses, lights and audio are constructed at runtime in GDScript. GLB imports may carry their own geometry/material metadata; they are not separately tracked texture files.
- This repository is a stylized, mostly procedural prototype, not a production content pipeline. Visible generated details do not necessarily have collision, navigation or interaction.

# A. Project overview

## Concept and design

An offline, third-person/over-shoulder stealth-sandbox prototype. BLACKLINE is the player's employer, Ruby is the handler, and the Covenant is a separate organization. Missions combine observation, access/disguise, evidence, conversations, objective targets and extraction. The story campaign begins with **Initiation**, retains optional legacy **The Meridian**, then advances through five early Hong Kong operations: **Tung Chung → The Streets → The District → The Harbour → Ngong Ping**. Standalone map previews are explorations, not campaign progress.

Design intent in the current build: non-graphic, small-scope stealth mechanics; legible objectives without health or omniscient radar; replayable missions and versioned independent persistence; subdued stylized procedural art/audio; compatibility with lower-end/integrated graphics. Those are intentions and prototype constraints, not verified quality claims.

## Technology and hardware target

- Engine: Godot **4.4.1** is the documented/CI version (the project declares compatibility feature `4.4`).
- Main language: GDScript. Mission/campaign/population content is JSON. Tests are GDScript `SceneTree` scripts plus Python `unittest`.
- Renderer: `gl_compatibility` (Godot Compatibility / OpenGL path). Mobile rendering method is also set to Compatibility.
- Display baseline: 1280×720, canvas-item UI stretch; settings additionally offer 1600×900 and fullscreen/windowed.
- Intended test machine in `WINDOWS_PLAYTEST_CHECKLIST.md`: Windows laptop, Intel i5-1335U, 16 GB RAM, Intel Iris Xe. Actual model/driver/OS details and Iris Xe performance were **not measured** in this audit. CI software-renderer numbers are not a hardware benchmark.
- No external AI services, networked gameplay or runtime network dependency is present in the inspected game systems.

## Main runtime systems

1. **Campaign service** loads mission/equipment definitions, validates progression, persists campaign state and settings, configures rendering/audio buses and changes scenes.
2. **World composition**: `HotelWorld` (`hotel.gd`) constructs the Meridian in code; `InitiationWorld` inherits/reuses it with its own room/population/objectives. `HongKongOperation` composes shared station/city/mountain map builders with per-operation config. Three preview builders are separate from campaign operations.
3. **Player/NPC**: `HotelPlayer` is a `CharacterBody3D`; `HotelNpc` has local schedule, navigation, perception and short-lived memory. `StylizedPerson` builds a primitive articulated visual rig.
4. **Mission/equipment**: validated evidence/action/target state; training pulse, optional Quiet Line, and temporary coin distraction. Hong Kong keys are their own permanent campaign flags and are distinct from evidence/coins.
5. **Persistence**: independent campaign, settings and mission checkpoint files; write-through temp file and backup; validation and explicit legacy migration paths.
6. **UI/audio**: dynamically composed menu, tracker, loadout, settings, pause, debrief and secure-channel UI; code-generated WAV tones/ambience/footsteps, AudioServer buses.

# B. Complete asset inventory

## Identifier policy

Exact Godot paths below are repository-relative paths (the runtime form is shown as `res://…`). There are no checked-in resource UIDs. “No UID” below means none was present in the inspected source, not that an editor import will never generate a local UID. Script-built resources have no standalone `.tres` IDs.

## Imported models (all nine checked-in model files)

All are unmodified Kenney Furniture Kit 2.0 GLBs, CC0 1.0, provenance and source pin in `assets/kenney_furniture/PROVENANCE.md`; material overrides/transforms/collision are project code. Status: **used**. No embedded Godot UID is recorded in repository source.

| Exact path / filename | Type, references and use | Description/status/provenance |
|---|---|---|
| `assets/kenney_furniture/bedDouble.glb` | GLB 3D model; `scripts/visuals/hotel_furniture.gd` (`BED`) | Guest/suite beds in Meridian extension. Used. Kenney CC0; project overrides palette/placement. |
| `assets/kenney_furniture/books.glb` | GLB; `hotel_furniture.gd` (`BOOKS`), `world/landscape_preview.gd` | Suite reading detail and city office desk. Used. Kenney CC0. |
| `assets/kenney_furniture/chairCushion.glb` | GLB; `hotel_furniture.gd` (`DINING_CHAIR`), `landscape_preview.gd` | Meridian dining chairs and city office chairs. Used. Kenney CC0. |
| `assets/kenney_furniture/lampRoundFloor.glb` | GLB; `hotel_furniture.gd` (`FLOOR_LAMP`) | Meridian west-wing floor lamps. Used. Kenney CC0. |
| `assets/kenney_furniture/laptop.glb` | GLB; `hotel_furniture.gd` (`LAPTOP`), `landscape_preview.gd` | Meridian and city-office desk prop. Used. Kenney CC0. |
| `assets/kenney_furniture/loungeChair.glb` | GLB; `hotel_furniture.gd` (`ARMCHAIR`) | Meridian suite reading area. Used. Kenney CC0. |
| `assets/kenney_furniture/loungeSofaLong.glb` | GLB; `hotel_furniture.gd` (`SOFA`) | Meridian lobby/west wing seating. Used. Kenney CC0. |
| `assets/kenney_furniture/pottedPlant.glb` | GLB; `hotel_furniture.gd` (`PLANT`), `landscape_preview.gd` | Meridian and city-office set dressing. Used. Kenney CC0. |
| `assets/kenney_furniture/tableCoffeeGlass.glb` | GLB; `hotel_furniture.gd` (`COFFEE_TABLE`) | Meridian lounge/west-wing tables. Used. Kenney CC0. |

`assets/kenney_furniture/LICENSE.txt` (CC0 text) and `assets/kenney_furniture/PROVENANCE.md` (origin/source commit/file list) are accompanying provenance files, not runtime game assets. No model is identified as unused or deprecated in the current source.

## Scenes (14 authored `.tscn` files)

Each contains a small root and attaches its listed script; most environment nodes are created procedurally on `_ready()`. Godot path is also the stable resource identifier here. All are current/used either by menu/campaign, integration tests or previews.

| Exact scene path | Attached logic / references | Role and status |
|---|---|---|
| `scenes/main_menu.tscn` | `scripts/ui/main_menu.gd` | Main entry, campaign/mission selection, loadout and settings. Used; `project.godot` main scene. |
| `scenes/initiation.tscn` | `scripts/world/initiation.gd` | Assessment lesson/tutorial mission; reuses hotel world code. Used. |
| `scenes/hotel.tscn` | `scripts/world/hotel.gd` | Optional legacy Meridian campaign mission. Used. |
| `scenes/mission_tung_chung.tscn` | `scripts/missions/hong_kong_operation.gd`, export `operation_id="tung_chung"` | First Hong Kong operation and physical train extension. Used. |
| `scenes/mission_the_streets.tscn` | shared operation script, `operation_id="the_streets"` | Market operation. Used. |
| `scenes/mission_the_district.tscn` | shared operation script, `operation_id="the_district"` | District records operation. Used. |
| `scenes/mission_the_harbour.tscn` | shared operation script, `operation_id="the_harbour"` | Waterfront operation. Used. |
| `scenes/mission_ngong_ping.tscn` | shared operation script, `operation_id="ngong_ping"` | Mountain field archive operation. Used. |
| `scenes/ending.tscn` | `scripts/ui/ending.gd` | Mission results/debrief and continuation. Used. |
| `scenes/ruby_meeting.tscn` | `scripts/cinematics/ruby_meeting.gd` | Post-Initiation skippable handler scene. Used. |
| `scenes/usb_decryption.tscn` | `scripts/ui/usb_decryption.gd` | One-time secure-channel story event after the five keys and last operation. Used. |
| `scenes/tung_chung_preview.tscn` | `scripts/world/tung_chung_preview.gd` | Standalone station exploration; separate from campaign mission. Used as preview. |
| `scenes/hong_kong_preview.tscn` | `scripts/world/landscape_preview.gd` | Shared city/neighbourhood exploration preview. Used as preview. |
| `scenes/ngong_ping_preview.tscn` | `scripts/world/landscape_preview.gd` | Mountain exploration preview. Used as preview. |

## JSON data files (all five)

| Exact path | Identifier/content and consumers | Status |
|---|---|---|
| `resources/campaign.json` | Employer/handler text, ordered mission IDs/scenes/briefings/debriefs/keys, equipment definitions; read by `CampaignState._ready()` then validated by `CampaignProgress.configure()`. | Active source of campaign sequence, equipment eligibility and briefing content. |
| `resources/initiation_mission.json` | Three lesson records `evaluation`, `sensor_log`, `dispatch`; required count 3; action `disable_assessment_unit`; target metadata. Consumed by `InitiationWorld`/`Mission`. | Active. |
| `resources/meridian_mission.json` | Three records (`ledger`, `memo`, `archive`), any two required, `interview_ivo`, Adrian Locke primary and schedule. Consumed by `HotelWorld`/`Mission`. | Active. |
| `resources/hong_kong_operations.json` | Per-operation map, target, key placement/hints/positions, spawn/extraction, lines, witness, optional intel. Read by `HongKongOperation`. | Active. |
| `resources/hotel_population.json` | Three named hotel NPC profiles, occupations/alertness/start/schedules. Parsed by hotel composition root. | Active base hotel population data; additional target/wing NPCs are built by code. |

## Shaders (both)

| Exact path | Runtime use | Status |
|---|---|---|
| `shaders/meridian_floor.gdshader` | Preloaded by `scripts/world/hotel.gd` as procedural Meridian floor finish. | Used. |
| `shaders/neighbourhood_paving.gdshader` | Preloaded by `scripts/world/hong_kong_annex.gd` for the city-neighbourhood paving. | Used. |

## Procedural/runtime assets and absence inventory

These are generated by code at run time and therefore have **no separate file, UID, original external source or import record**:

- Geometry, signage, collision and material instances: `scripts/world/hotel.gd`, `initiation.gd`, `hong_kong_annex.gd`, `landscape_preview.gd`, `tung_chung_preview.gd`, `scripts/visuals/environment_dressing.gd`, `hotel_furniture.gd`.
- Character primitive meshes/poses and roles: `scripts/visuals/stylized_person.gd`; the Kenney meshes are the exception for furniture.
- Music-like ambience beds, UI tones, footfalls, alert/weapon sounds: generated WAV streams in `scripts/audio/procedural_sound.gd`; no recorded audio assets or authored music/dialogue files exist. Ruby speech is subtitles/text, not a voice recording.
- Animations: timed transforms/procedural gait and pose code, including `ruby_meeting.gd`, `hong_kong_operation.gd`, `HotelNpc`, `HotelPlayer`, `StylizedPerson`; no animation resource files or production skeletal animation pipeline are checked in.
- UI artwork/icons/fonts: drawn controls/vector icons/labels and built-in Godot theme fonts; no external icon, image, or font asset files are checked in.
- Textures: no standalone image texture files found. A generated material may use color/primitive properties, not an image texture.
- `assets/kenney_furniture/PROVENANCE.md` and `LICENSE.txt`: documentation/licensing, not in-game. No asset in the checked-in tree is confidently classified deprecated; unreferenced/prototype content is described as such rather than removed.

# C. Complete script inventory

The inventory below covers all 41 scripts in `scripts/`; most are active runtime dependencies and `scripts/disguise/disguise.gd` is an unused schema/foundation (no references were found). Test files are inventoried separately in section H. Function names below were extracted from checked-in top-level GDScript declarations; this is an API index, not an assertion that every helper is a public API. Global class names and signals are stated when defined.

| Exact path / class | Purpose, key state/signals, main functions and connections |
|---|---|
| `scripts/audio/procedural_sound.gd` / `ProceduralSound` | Static `tone`, `footstep`, `ambience`; generates looping/non-looping `AudioStreamWAV` in code, caches ambience. Used by menus, player/world/mission/cinematics; no source audio files. |
| `scripts/cinematics/ruby_meeting.gd` | Post-Initiation 3D handler sequence; timeline, characters, door/exterior and skip input. `_ready`, `_build_exterior`, `_box`, `_process`, `_apply_timeline`, `_unhandled_input`, `_finish`; calls campaign progression and procedural sound; transition returns to campaign. |
| `scripts/core/campaign_progress.gd` / `CampaignProgress` | Data-only ordered progression: lessons/coins, completed missions, selected equipment, five keys, decryption status, last mission. `configure`, `mission`, `is_unlocked`, `next_mission`, `mark_complete`, `award_lesson`, `set_equipped_coins`, `item_unlocked`, `item_allowed`, `select_item`, `secure_key`, `usb_ready`, `restore`, `snapshot`. Used by autoload and tests. |
| `scripts/core/campaign_state.gd` / autoload `Campaign` | Loads campaign JSON, state/settings, safe checkpoint path lookup, scene transitions, records mission result, handles lesson/key/decryption writes, graphics/window/camera/audio application. `persist`, `checkpoint_path`, `has_checkpoint`, `begin`, `award_initiation_lesson`, `secure_mission_key`, `acknowledge_usb_decryption`, `complete`, `item_label`, `_load_settings`, `configure_camera`, `apply_settings`, `save_settings`. Main dependency of menu, missions, UI. |
| `scripts/disguise/disguise.gd` / `DisguiseDefinition` | Small Resource with exported `display_name`, enum `role` (visitor/staff/security/manager) and `color`. No references were found in scripts/scenes/tests; currently unused foundation. Gameplay applies role/material directly from player/world rather than a substantial authored disguise-resource pipeline. |
| `scripts/equipment/coin_distraction.gd` / `CoinDistraction` | Static `use`: deploys coin, reduces temporary stock and directs eligible local NPCs to investigate landing point. Called from hotel/HK world. |
| `scripts/equipment/equipment.gd` / `MissionEquipment` | Deployment-specific selected item, five training charges and remaining coins. `configure`, `select_slot`, `snapshot`, `restore`; validates selected items via `CampaignProgress`. |
| `scripts/interactions/interactable.gd` / `Interactable` | Node with availability/use state and `activated` signal; `available`, `interact`. World composes records, target/witness, key, uniform, intel, exit. |
| `scripts/inventory/inventory.gd` / `Inventory` | Unique carried record IDs/capacity, `changed`; `add`, `has_item`, `clear`. Mission owns evidence threshold; world collects. |
| `scripts/missions/hong_kong_operation.gd` | Shared campaign scene runtime for five ops: sets up selected map, NPCs, mission markers/HUD, entry/escape/contact/extraction presentations, train, target/key gates and isolated save. Signals are driven mainly via player/interaction methods and input, not declared custom signals. API: `_ready`, `_build_markers`, `_part`, `_build_ui`, `_begin_intro`, `_end_intro`, `_skip_cinematic`, `_input`, `_unhandled_input`, `_next_objective`, `_process`, `_highlight_optional`, `_overlay`, `_reachable`, `_interact`, `_begin_story`, `_drop_station_key`, `_advance_story`, `_finish_story`, `_begin_extraction`, `_finish_extraction`, `_board_train`, `_enter_train`, `_sync_train_gate`, `_build_train`, `_train_solid`, `_secure_key`, `_on_trespass_notice`, `_select_equipment`, `_use_equipment`, `_throw_coin`, `_fire`, `save_game`, `load_game`. State includes operation ID/config, map/player/NPC refs, witness/intel/uniform/key, camera phases, target/key completion, train stage/contact/passengers, HUD, visuals/audio. Depends on campaign JSON/progress, builders, player/NPC, procedural audio and pause/tracker UI. |
| `scripts/missions/mission.gd` / `Mission` | Validates mission-record JSON and primary target; tracks unique clues, required action, primary target, extraction, `changed`/`completed`. `configure`, `has_record`, `record_clue`, `mark_action`, `mark_target`, `can_extract`, `extract`, `progress_text`, `objective_text`, `_valid_point`. Used by hotel/Initiation; snapshots restore validated values. |
| `scripts/npc/npc.gd` / `HotelNpc` | `CharacterBody3D`, local navigation/schedule/perception/suspicion/memory, warning/escalation, disturbance reporting and temporary incapacitation. Signals `state_changed`, `trespass_notice`. Functions: `_ready`, `set_state`, `complete_objective`, `restore_objective`, `incapacitate`, `observe_trespass`, `warn_trespass`, `tick_trespass`, `_notify_nearby_security`, `observe_incapacitated`, `_seek_help`, `_try_deliver_report`, `_fire_alert_pulse`, `_player_access_area`, `_permitted_exit`, `advance_simulation`, `can_see`, `observe_disturbance`, `_physics_process`. Consumes profile/player/world area helpers; drives `StylizedPerson`. |
| `scripts/npc/npc_memory.gd` / `NpcMemory` | Per-NPC expiring observations; `observe`, `tick`. NPC memories are intentionally local, not globally broadcast. |
| `scripts/npc/npc_profile.gd` / `NpcProfile` | Resource fields: identity, occupation, alertness/curiosity/sociability/patience/confidence, schedule. Populated from hotel JSON and per-mission builder code. |
| `scripts/npc/schedule_entry.gd` / `ScheduleEntry` | Resource destination/activity/duration; `_init`. Used by NPC profiles and navigation routines. |
| `scripts/player/player.gd` / `HotelPlayer` | Player movement, camera/spring arm, stance/aim/Instinct, equipment, footstep, input. Signals `interaction_requested`, `equipment_use_requested`, `coin_requested`, `equipment_selected(slot)`, `fire_requested`. Functions: `_ready`, `set_disguise`, `_unhandled_input`, `_notification`, `shot_feedback`, `receive_alert_pulse`, `_physics_process`, `_can_stand`. World scripts connect signals to interactions/fire/equipment. |
| `scripts/save/save_store.gd` / `SaveStore` | Static JSON persistence, version 1, temp-write and `.bak` fallback/recovery. `write`, `read`, `_read_one`; used by campaign/settings and per-mission snapshots. |
| `scripts/save/session_snapshot.gd` / `SessionSnapshot` | Captures/restores player position/role/equipment, clues/actions/targets and marker states with validation/migrations. `capture`, `restore`, `_number`; used by Meridian/Initiation. HK operation has its own extended snapshot code in its world script. |
| `scripts/stealth/access.gd` / `AccessRules` | Static role/zone rule helpers `can_enter`, `area_at`; used with position-based hotel zones. Disguise/access remains simple prototype logic. |
| `scripts/stealth/disturbance_system.gd` / `DisturbanceSystem` | Periodically checks whether conscious NPC can see incapacitated people and asks observer to investigate locally; `_physics_process`. Added to world composition, not global omniscient alert. |
| `scripts/ui/aim_reticle.gd` | Draws aiming/impact feedback; `confirm_hit`, `_process`, `_draw`. Created by mission world. |
| `scripts/ui/blackline_theme.gd` / `BlacklineTheme` | Creates project-wide procedural `Theme`/styles; `create`, `_style`. Used by dynamic UI. |
| `scripts/ui/ending.gd` | Mission debrief, optional objective result and continue/replay selection; `_ready`, `_label`, `_process`, `_unhandled_input`, `_continue`. Reads `Campaign.ending`. |
| `scripts/ui/equipment_icon.gd` | Procedurally draws selected equipment icon; `_ready`, `set_item`, `_draw`. HUD helper. |
| `scripts/ui/interaction_reticle.gd` | Procedural center reticle drawing; `_ready`, `_draw`. Player/world HUD. |
| `scripts/ui/main_menu.gd` | Main menu, campaign mission cards/briefing, preview navigation, loadout coin/item selection, settings, SFX. `_ready`, `_build_shell`, `_clear`, `_text`, `_button`, `_home`, `_missions`, `_previews`, `_briefing`, `_start`, `_loadout`, `_cycle_coins`, `_select_item`, `_settings`. Uses `Campaign`, scenes, settings panel. |
| `scripts/ui/menu_backdrop.gd` | Draws abstract procedural menu backdrop; `_ready`, `_draw`. Used in menu. |
| `scripts/ui/mission_intro.gd` | Generic intro overlay/skip logic; `_ready`, `_process`, `_input`, `end_intro`. Reusable UI, while HK campaign currently contains its own richer intro handling. |
| `scripts/ui/mission_tracker.gd` | Mission HUD/tracker and objective labels; Tab collapses, O reveals optional objectives; `collapsed`, `show_optional`, `set_state`; `_ready`, `_label`, `_unhandled_input`, `_visibility`, `_process`. Used by hotel/HK worlds. |
| `scripts/ui/pause_menu.gd` | Pause/resume/return/settings panel and confirmation; `_ready`, `_input`, `_open`, `_resume`, `_clear`, `_label`, `_button`, `_main`, `_settings`, `_confirm`. Instantiated during campaign play. |
| `scripts/ui/settings_panel.gd` / `SettingsPanel` | Dynamic settings controls and `back_requested`; `_ready`, `_add_row`, `_save`. Writes settings immediately through `Campaign`. |
| `scripts/ui/usb_decryption.gd` | Final skippable secure-channel/decryption presentation, no invented USB content; `_ready`, `_process`, `_unhandled_input`, `_finish`. Uses campaign acknowledgement and debrief route. |
| `scripts/visuals/environment_dressing.gd` / `EnvironmentDressing` | Procedural decorations/materials/instanced batches/lights for hotel, wing, annex. `build`, `_part`, `_batch`, `_sign`, `_lamp`, `_sofa`, `_plant`, `_hotel`, `_dining_crockery`, `_hotel_wing`, `_annex`. Quality groups control detail/practicals. Many props visual-only. |
| `scripts/visuals/hotel_furniture.gd` | Instantiates nine referenced Kenney GLBs and overrides palette/transform; `build`, `_place`, `_apply_palette`. Called from hotel/landscape composition. Physical collision is separate code. |
| `scripts/visuals/stylized_person.gd` / `StylizedPerson` | Procedural low-poly person mesh, role appearance, weapon/interaction pose, gait and footfalls. `add_sidearm`, `add_quiet_tool`, `use_quiet_tool`, `fire_weapon`, `interact`, `_role_color`, `set_role`, `animate_motion`, mesh/material helpers. Used by player/NPC/cinematics/passengers. Not production skinned animation. |
| `scripts/world/hong_kong_annex.gd` | Builds neighbourhood extension/rooms/routes, intel/uniform positions, bounds and materials. `_box`, `_sign`, `build`, `_room`, `intel_world_position`, `uniform_world_position`, `contains_world_position`, `_process`. Instantiated in HK campaign. |
| `scripts/world/hotel.gd` (no `class_name`) | Active Meridian composition root and reusable Initiation base; state includes save path, player, `Mission`, interactables/NPCs/primary, HUD widgets and audio. Builds environment/wing/player/NPCs/interactions/UI, connects signals, handles access/Instinct/equipment/fire/interact/save/load/checkpoint collision and prompt updates. Exact declared methods: `mission_id`, `mission_path`, `safe_position`, `_ready`, `_finish_entry_intro`, `_box`, `_collision_box`, `_build_environment`, `_hotel_window`, `_build_meridian_wing`, `_build_player`, `_vector`, `_build_npcs`, `_wing_guest`, `_add_interactable`, `_pickup_detail`, `_build_interactions`, `footstep_surface`, `_build_ui`, `_on_trespass_notice`, `_select_equipment`, `_use_equipment`, `_throw_coin`, `_fire`, `_impact_flash`, `_shot_trace`, `_clear_reach`, `_setup_instinct`, `_highlight_material`, `_overlay_recursive`, `_target_node`, `_in_player_view`, `_update_instinct`, `_nearest`, `_interact_nearest`, `_on_interaction`, `save_game`, `load_game`, `_resolve_furniture_checkpoint`, `_checkpoint_query`, `_new_furniture_overlaps`, `_standing_space_clear`, `_unhandled_input`, `_process`. Uses Campaign/Mission/Player/NPC/HotelLayout/AccessRules/Interactable/SessionSnapshot/SaveStore and UI helpers. `initiation.gd` overrides selected builder/mission functions. |
| `scripts/world/hotel_layout.gd` / `HotelLayout` | Static hotel navigation mesh and safe-position bounds; `navigation_mesh`, `is_safe_player_position`; shared by hotel snapshots/tests. |
| `scripts/world/initiation.gd` | Subclass/configuration for Initiation geometry, two guards, moving assessment unit, lesson interactions and validation; `mission_id`, `mission_path`, `safe_position`, `_build_environment`, `_build_player`, `_build_npcs`, `_guard`, `_build_interactions`, `_robot_part`, `_on_interaction`, `_physics_process`. Reuses hotel. |
| `scripts/world/landscape_preview.gd` (extends `tung_chung_preview.gd`; no `class_name`) | Active city/Ngong Ping preview builder and shared HK neighbourhood composition; exported `preview_kind`, batched accent/canopy transforms/colors. Exact declared methods: `_ready`, `footstep_surface`, `_accent`, `_flush_accents`, `_flush_canopies`, `_city_walkway`, `_terrain_patch`, `_village_roof`, `_scene_population`, `_process`, `_ground`, `_parked_car`, `_parked_bus`, `_city`, `_is_operation_interior`, `_operation_interior`, `_mountain`, `_mountain_field_office`, `_buddha_approach`, `_landmark_part`, `_sphere`, `_peak`. Builds procedural visuals/NPCs/interiors; shares station preview player/navigation helpers. Used by city/mountain preview scenes and HK map builder as invoked by operation. |
| `scripts/world/tung_chung_preview.gd` | Standalone station exploration preview; environment, station mesh/navigation, population, local interaction/status/escape to menu. No campaign key/train mission-state progression. |

### System communication and scene lifecycle

```text
main_menu.tscn + main_menu.gd
        │ Campaign.begin(id[, resume])
        ├── initiation.tscn → InitiationWorld → HotelWorld composition
        ├── hotel.tscn → HotelWorld (Meridian)
        └── mission_*.tscn → HongKongOperation(operation_id)
                 │ map builder + player/NPC/equipment/tracker
                 │ physical objectives → Campaign secure_key/complete
                 ├── ending.tscn → menu or next mission
                 └── usb_decryption.tscn after final key/Ngong Ping → debrief

Campaign (autoload) owns progression/settings, not mission checkpoint actors.
HotelWorld uses Mission + SessionSnapshot; HongKongOperation has a mission-specific snapshot.
Player signals → world composition root → interactable/NPC/mission/equipment → tracker/UI.
NPC signals (`state_changed`, `trespass_notice`) → local world HUD/message/reaction.
```

Mission completion is recorded before the post-mission camera presentation, so skipping presentation must not award a second completion. Previews return to selector/menu and should not write campaign progress.

# D. Game architecture

## Scene tree / composition

The `.tscn` roots are deliberately minimal. Most visible child nodes are built procedurally at runtime by attached scripts. `hotel.gd` is both a high-level world composition root and mission event dispatcher; it is not a reusable content pipeline. `initiation.gd` inherits it, overrides mission/world content and keeps common player, NPC, UI, and save behavior. HK scenes are separate tiny roots parameterized by `operation_id`, but one large script does map selection, operation logic, UI and cinematics. This concentration is a maintenance risk; preserve behavior before refactoring.

## Autoload and persistence boundaries

`Campaign` is the sole autoload. It loads `campaign.json`, `blackline_campaign.json` and `blackline_settings.json`. Campaign data is chronological/validated; per-operation keys gate completion, and future keys in malformed/out-of-order saves are rejected. The mission checkpoint path method preserves existing Meridian and Initiation names and assigns five separate Hong Kong checkpoint names. Settings are independent from campaign and mission checkpoint content.

`SaveStore.VERSION = 1`: writes a `.tmp`, flushes and rotates a valid existing file to `.bak`, then renames; reads primary and falls back to backup. Do not change format/version without considering recovery/migration. Mission checkpoint snapshots do not persist NPC schedules/suspicion/temp incapacitation (except completed primary outcome/pose), and intentionally filter positions against safe bounds.

## Player, camera and controls architecture

`HotelPlayer` uses `CharacterBody3D`, a spring arm and camera, mouse-look, stance capsule/visual offsets and procedural body rig. Aiming interpolates shoulder/FOV; firing is a ray/pulse, not projectile ballistics. Crouch changes speed and physical/visual stance; it is not an arbitrary NPC visibility multiplier. Walls and cover matter through actual collision/line of sight. Instinct is held and highlights the briefing-defined primary through geometry (red), and nearby visible/clear objective items (yellow), not all NPCs or hidden objects.

Project Input Map and script-level HUD controls:

| Input | Default |
|---|---|
| Move | WASD (`move_forward/back/left/right`) |
| Sprint / crouch | Shift / C |
| Interact | E |
| Save / load checkpoint | F5 / F9 |
| Release mouse / pause or skip active presentation | Escape (`release_mouse`; behavior depends on current scene/state) |
| Equipment slots | 1 / 2 |
| Use currently selected equipment | Q |
| Throw coin | G |
| Aim / fire | Hold right mouse / left mouse |
| Instinct | Hold left Ctrl |
| Tracker | Tab toggles collapse/minimize |
| Optional objective panel | O toggles visibility |

Some preview interactions are intentionally simpler than campaign controls. Settings are editable at runtime via the Godot Input Map only if the project implements it; no rebinding screen is present.

## NPC AI and navigation

`HotelNpc` combines profile schedule, `NavigationAgent3D`, short local memory and throttled player perception (documented default 0.4s cadence, approx 7m / 120° for base implementation). Area access is position-derived in some scenes. NPC state transitions cover idle/scheduled movement, suspicion/investigation/return, warn/trespass and temporary incapacitation. A nearby witness can seek nearby security once with local line-of-sight/range constraints; security alert uses fictional short-stagger pulses blocked by solid cover. NPCs do not share global radio/omniscient awareness. Disturbance observers individually check line of sight. Schedules are deterministic/local and do not represent full social simulation, crowd schedules or clock time.

Navigation is authored/generated specifically for clear routes. Hotel upper floors are not fully connected to original-floor navigation; HK local paths are not comprehensive obstacle-aware navigation. Station mesh has deliberate holes around pillars/information island. Route soak tests cover selected routes, not all blockers or user movement.

## Combat, stealth, equipment and interaction

- Training sidearm: fictional unsuppressed pulse, five charges, aimed centre-ray; obstruction check; temporarily incapacitates ordinary NPCs and prompts local reaction. Target hit/interaction can complete mission primary according to context.
- Quiet Line: unlocked after Initiation; Q temporarily incapacitates one nearby unobstructed person. Not in Initiation. This is not physical restraint/ballistics.
- Coins: temporary mission stock, G deploys to distract/investigate locally. Never consume permanent campaign lesson rewards.
- Disguises: role switch to staff via mission pickup; can grant staff-area access, not security-only/secure access. A role is not complete visual identity/recognition simulation.
- Interactions: `Interactable`/nearby ray/distance triggers records, witness/target, physical key, uniform, optional intel, extraction. Evidence, optional clues and key are separate.

No health, realistic damage, ammo reload, full combat loop, coordinated hunt or complete cover system is present. Avoid implying otherwise.

## Objectives, mission completion and cinematics

Hotel `Mission` requires configured unique records and any required action/target before extraction. Meridian has 3 records, requires any 2 plus Ivo interview and Adrian completion. Initiation requires all 3 lessons/records and disabling assessment unit. HK operation has its own mandatory target/key/extraction state; witnesses and intel are optional. Campaign uses separate key state. HUD renders objective/stage/status/optional/message, equipment and key status.

HK cameras and short story scenes are scripted in GDScript, not an authored camera/animation timeline. Entry shows location/target; each is Escape-skippable. Extraction completion is saved before a short follow-up camera, skippable. In Tung Chung, story-driven events are as detailed under section E. The final secure-channel screen is a fictional unresolved-data event: it must not imply an implemented decryption result.

## Audio buses and generated audio

`Campaign.apply_settings()` ensures buses named `Master`, `Music`, `SFX`, `Ambient`, `Dialogue` exist, routes each non-master to Master, sets independent dB/mute levels from linear sliders and reapplies settings live. Most synthesized menu/game effects use SFX; ambient loops include hotel/station/city/mountain and train. Current content has no authored music track and no voiced dialogue, so Music/Dialogue sliders can be changed/persisted but have little/no dedicated content to audition. Audio fidelity/review was not performed.

## Rendering and quality settings

`Campaign.settings` saves LOW/MEDIUM/HIGH, resolution/fullscreen, mouse sensitivity, show FPS, shadow toggle, practical local-light toggle and far-view toggle. LOW sets 70% 3D scale and disables shadow atlas/practicals/fine details; MEDIUM 85% and 1024 atlas; HIGH 100%, FXAA, 2048 atlas, high detail/reflection probes; MSAA disabled. Shadow and local lights can be toggled separately except LOW forces them off; far clip is 220m vs 75m. These are real code controls, not platform-specific benchmark evidence.

# E. Mission documentation

## INITIATION — training and permanent lesson rewards

`scenes/initiation.tscn` + `scripts/world/initiation.gd` inherit/reuse hotel composition. Fictional Civic Evaluation Annex. Ruby's brief: disable moving assessment unit, collect all records, exit; two guards are present. Mission data requires all three records plus `disable_assessment_unit`.

| Lesson | Persistent record ID | Data label/teaching concept | Reward |
|---|---|---|---|
| 1 | `evaluation` | “Observation: read evaluation sheet” | One permanent coin, once. |
| 2 | `sensor_log` | “Awareness: copy sensor log” | One permanent coin, once. |
| 3 | `dispatch` | “Evidence: retrieve dispatch record” | One permanent coin, once. |

The assessment unit moves on a simple scripted path and can be disabled; two guards use base NPC logic. Completion unlocks optional Meridian and Quiet Line, campaign continuation leads to Ruby meeting (Escape skip), then Hong Kong next mission is available. Exact lesson positions/messages are in `resources/initiation_mission.json`. F5/F9 use `user://initiation_save.json`; campaign coins persist separately.

## MERIDIAN — optional legacy hotel operation

`scenes/hotel.tscn`, `resources/meridian_mission.json`, `resources/hotel_population.json`. Fictional luxury hotel/archive-transfer investigation; preserve legacy mission/save. Target Adrian Locke, operations director; witness Ivo Chen, records employee. Three evidence records (`ledger`, `memo`, `archive`), collect any two. Interview Ivo (`interview_ivo`), complete Locke primary (confront/tag), then exit. Visitor/staff/secure access zones and disguise exist in simplified role-based form. NPCs: Mara Vale (security), Ivo Chen (employee/witness), Nadia Sol (civilian), plus Locke, wing visitors/guests. A connected west wing/upstairs rooms and private suite extend original hotel, with ramp; navmesh is not a connected floor-to-floor agent route. Exit/debrief presents result. Meridian is optional and does not gate HK chapters after Initiation. Checkpoint remains `user://meridian_save.json` for compatibility.

## HONG KONG campaign commonality

Five operations are ordered and each needs its own physical target objective, physical operation-specific USB key and extraction. A witness and optional intel add debrief context but are not mandatory/key sources. `resources/hong_kong_operations.json` is exact source of names, placement/coordinates/text. Three city operations share an original 90×90m city footprint plus 70×70m fictional neighbourhood extensions (4,900m² gross additional per operation, ~60% over original footprint), not 15×. The city missions have unique accessible interiors but share the same base layout. Mountain is a separate blockout. All maps are procedural/stylized; no human cultural/location review has been completed.

### 1. Tung Chung

- **Setting/story:** fictional station/courier handoff. Target Kai Venn, train courier. Platform attendant is optional witness; elevated concourse departure note is optional intel. Key 01 begins with courier; after confrontation it becomes a separate physical pickup. Contact confirms market intermediary lead. Train passengers are background visual scenery, not interactive NPC dialogue.
- **Mission logic:** confront target first. Confrontation marks target complete, drops key onto concourse and starts the five-second **Escape** scripted presentation. It moves the target along two scripted path segments; agent control and target collision/AI are disabled. The target then disappears/escapes. The physical Key 01 remains unsecured; player regains control and must walk to/interact at drop location. Escape skip finalizes same state; skip does not award key.
- **Platform/boarding:** target complete + key secured + escape presentation complete opens the platform gate. The player physically walks along platform through the doorway; threshold/collision logic advances `train_stage` to `aboard` (also checkpoint migration can set aboard position in test setup). These are playable player-controlled traversal sections, not a teleport/cutscene. Carriage is code-built with collision and two connected car bodies; no real train or rail system.
- **Inside train:** player walks through connected carriages toward Kai/contact and final exit. On first physical boarding, a 5.2-second **departure cutaway** switches to a separate, fictional non-interactive exterior set with a moving camera/light streaks; it does not reposition the saved player or simulate a navigable rail journey. It is skippable, and natural completion/skip restores the playable carriage. `train_departure_seen` is saved so it is not replayed; old aboard checkpoints migrate as already seen. The later five-second **contact story** remains scripted/cinematic and non-interactive: two procedural characters move in a small exterior/roof-like scene while camera follows; contact confirms the next lead and is skippable. Four seated procedural passenger props are placed across the two carriages; they are not interactive NPC dialogue. Looping procedural train ambience and moving exterior streaks remain decoration, not an authentic rail simulation.
- **Exit/resolution:** contact completion enables forward carriage exit. Player walks to extraction and presses E. Campaign completion/Key 01 state is committed, then a short skippable extraction camera (three seconds by default) transitions to debrief. This is the final operation resolution, not a continuous cinematic escape. The departure cutaway is a source-level addition only; its runtime appearance, skip/restore behavior and checkpoint compatibility still need Godot validation.
- **Checkpoints:** `user://blackline_tung_chung_save.json` stores operation ID, target/key/witness/intel/uniform, key drop position, train stage/contact, player position and equipment. Loader validates matching key/mission, bounds and restores to safe state; target-complete old checkpoints converge on post-escape state rather than resuming mid-cinematic.

### 2. The Streets

- **Setting/story:** fictional market lanes and MARKET OFFICE, within shared city blockout plus market neighbourhood. Target Mina Lau, market intermediary, indoors; market vendor optional witness; market receipt optional intel. Target's bodyguard physically carries Key 02. Briefing/target line points to district records broker; extraction lead confirms next operation.
- **Objectives:** speak to target; collect Key 02 separately from bodyguard; optional vendor and receipt; reach extraction. Witness/intel don't grant key. Market/lookout/service room access and staff disguise are extra exploratory route affordances.
- **NPC/cinematics/checkpoint:** shared local NPC AI; target/bodyguard/witness and ambient visitors are scripted local agents. Skippable entry establishment and extraction camera; no authored extensive branching story. Checkpoint `user://blackline_the_streets_save.json`.

### 3. The District

- **Setting/story:** fictional commercial quarter / DISTRICT RECORDS interior, same city map family. Target Jonas Wu, district broker; records clerk witness; routing-slip optional intel. Key 03 is physically placed in records safe (not granted by target). Lead points to waterfront liaison.
- **Objectives:** broker primary; physical safe/key interaction; optional clerk and intel; extraction. Neighbourhood lookout and upper service room/disguise are optional.
- **NPC/cinematics/checkpoint:** local prototype NPC behavior, entry/extraction skippable cameras, checkpoint `user://blackline_the_district_save.json`.

### 4. The Harbour

- **Setting/story:** fictional waterfront extension/prom­enade and HARBOUR LIAISON, still shared city blockout (not a large separate authored harbour map). Target Elias Ng, waterfront liaison; quay attendant witness; quay ledger intel. Bodyguard carries Key 04. Target line points toward mountain archive.
- **Objectives:** liaison primary, physical key pickup from escort, optional witness/ledger, extraction. Service room/lookout route is optional.
- **NPC/cinematics/checkpoint:** shared local NPC logic, short entry and skippable extraction camera; checkpoint `user://blackline_the_harbour_save.json`.

### 5. Ngong Ping

- **Setting/story:** fictional mountain/village approach and field archive, with public Buddha landmark as static scenic landmark—not target, not destructible and not a secret facility. Target Sora Cheng, field coordinator; village guide witness; field memo intel. Key 05 is physically in FIELD ARCHIVE safe, separate from the public monument. Cultural/visual review is still needed.
- **Objectives:** target, physical safe/key, optional guide/memo, extraction; after all five keys and final operation completion, one-time secure-channel scene is opened (skip supported) and returns to debrief. No USB contents are revealed.
- **NPC/cinematics/checkpoint:** local prototype NPC and entry/extraction presentation; checkpoint `user://blackline_ngong_ping_save.json`.

### All five: route/cinematics truth

Every operation has a skippable entry briefing camera and short extraction camera; extraction gets saved before transition. Hong Kong operation script owns all five objective workflows. Optional witness/intel do not block extraction and do not award keys. The state machine is test-covered with synthetic inputs, including train route sections, but this does not establish collision/feel across full human playthroughs.

# F. Progression systems

## Permanent three-coin lesson system

- Permanent source records are exactly `evaluation`, `sensor_log`, `dispatch` (`CampaignProgress.LESSON_RECORDS`).
- Each valid record can grant its matching lesson once; duplicate/replay does not increase reward. The max is three.
- `Campaign.award_initiation_lesson()` only accepts while Initiation is active and persists to `user://blackline_campaign.json`.
- Legacy migration: an already-completed Initiation campaign save necessarily implies all three lessons; loading it migrates to all three. A partial legacy Initiation checkpoint migrates only validated recognized saved records. Unknown/duplicate lesson IDs rejected; equipped amount is clamped to earned count.
- Loadout cycles/selects coins up to earned amount; equipment is mission deployment state. `G` spends only `coins_remaining` of current deployment; successful use directs nearby eligible NPC attention. A new mission deployment replenishes to equipped amount. F5/F9 preserve remaining mission stock. Permanent lessons and equipped count are independent of temporary stock.
- Initiation does not permit coin use. This is unrelated to five USB keys and does not replace them.

## Five-key USB progression (separate system)

`key_01` … `key_05` map one-to-one to Tung Chung, Streets, District, Harbour, Ngong Ping. Keys only enter permanent `recovered_keys` after the corresponding physical pickup interaction and active mission/key-ID validation. Target completion never grants key. Campaign completion for a keyed mission is rejected without its own key; invalid/future keys are rejected when restoring campaign chronological state. `usb_ready()` requires exactly the five configured keys. Final Ngong Ping completion routes to `usb_decryption.tscn` once when all keys and state allow; acknowledgement persists. Mission checkpoint and campaign key collection are separate, so always preserve their relationship when changing save flow.

# G. UI, settings and controls

- **Main menu / Mission Selection:** dynamic script-built menu; campaign missions, replay, optional Meridian, previews, briefing/start/resume. Mission progression sourced from `campaign.json`. Preview scenes do not complete/save campaign.
- **Objective tracker:** dynamic title/stage/mandatory objective/status, equipment and key state, contextual message. `Tab` toggles minimized state; `O` toggles optional objective display. Verified by `hong_kong_campaign_test.gd` synthetic input checks.
- **Optional objective:** witness and intel states explicitly visible, optional, and do not gate extraction. Debrief counts optional result. HUD state displays key, extraction lock, equipped object/charges, coin stock.
- **Equipment HUD:** selected item/ammo or Quiet Line use prompt; no health meter. Instinct highlighter targets mission primary and nearby visible items only.
- **Loadout:** training sidearm always permitted; Quiet Line unlock after Initiation, only later missions. Coin amount cycles from 0 to earned limit; campaign selected equipment persists.
- **Settings:** window 1280×720 or 1600×900, fullscreen, mouse sensitivity, FPS display, LOW/MEDIUM/HIGH, shadows, local practical lights, far view, and five audio sliders. Changes are applied immediately and saved to `user://blackline_settings.json`; old master-only audio values retain default values for new buses.
- **Audio sliders/buses:** Master, Music, SFX, Ambient, Dialogue, independently routed to Master and persisted. Actual content is synthesized tones/ambient/footstep; no song or recorded dialogue. Testing verifies independent bus levels/mute/save/live slider, not perceived audio quality.
- **Lighting/graphics:** actual code settings and group-based toggles documented in section D; LOW forces shadows and practicals off, HIGH FXAA/full scale/high detail. Not an Iris Xe result.
- **Keybindings:** see table in section D. No remapping UI. Defaults are in `[input]` in `project.godot`; tracker controls Tab/O are handled in script rather than declared actions.

# H. Testing and build process

## Test files and responsibility

| Path | Coverage intent |
|---|---|
| `tests/test_project_data.py` | JSON/data integrity, unique population identities, schedule/navigation data, mission records/targets/routes, five distinct ordered keys, main scene/script references. Eight unit tests. |
| `tests/run_tests.gd` | Broad headless behavior regression: saves/backup/corruption/version, mission setup and evidence/target/extraction gates, interaction, player movement/collision/camera, NPC perception/navigation/access, Instinct, equipment/coins, Initiation, Meridian and campaign presentation flows; includes audio/settings and visual/cinematic assertions. |
| `tests/hong_kong_campaign_test.gd` | Integrated campaign order/key isolation, each HK map operation, required/optional objective and key separation, physical interactions, save/restore, staged transit and Tung Chung aboard/train contact/final extraction. Synthetic player path input is used for route-specific sections; actors may be frozen/noncolliding for route checks. |
| `tests/coin_progress_test.gd` | Three lesson rewards, duplicate protection, permanent save/migration, loadout bounds, mission stock persistence/replenishment, G distraction/local investigation. |
| `tests/npc_route_soak_test.gd` | Selected physical NPC route cycles in Meridian and station. Not full obstacle avoidance or crowd route certification. |
| `tests/camera_display_test.gd` | Xvfb/interactive-style camera input/capture, mouse release, yaw/pitch/clamp/spring-arm and display sampling. |
| `tests/instinct_render_test.gd` | Rendered screenshot comparison/through-wall Instinct highlight behavior. |
| `tests/cinema_capture_test.gd` | Cinematic and UI scene captures, settings/presets and screenshot metrics. |
| `tests/hong_kong_capture_test.gd` | Staged HK entry/environment/city/mountain/mission capture and visual checks. |

## Verified available results

- **Local in this audit:** `python3 -m unittest discover -s tests -p 'test_*.py' -v` ran **8 tests, all passed** (2026-11-16). Python 3.11.2. This verifies data-only checks, not Godot scripts/gameplay.
- **Local interactive/runtime:** no `godot`/`godot4` executable was installed in this workspace (`command -v` returned none). No graphical desktop, actual Windows machine, audio review or Iris Xe device was available. I did **not** run the game interactively or run GDScript suites locally.
- **Latest available CI evidence during this audit:** `Godot 4.4.1 regression` run [43826351110](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/43826351110) completed successfully on `ddf41938ef1934a3cc26a2d9cdf7c25473fe6ee3` (parent named by current HEAD; run inspected with `gh run view`). Both `headless` and `windows` jobs succeeded. The workflow reported success for Python data checks, import, startup, broad behavioral suite, integrated HK campaign, permanent coin system, NPC route soak, camera/display sampling, rendered Instinct, cinematic/UI, staged HK capture; Windows export and headless scene launches also passed. Existing `TESTING.md` records the suite counts at that run: Python 8, behavior 250, HK campaign 170, coin 31, NPC soak 20, camera 24, Instinct 15, HK staged visual 26, plus cinematic/UI suite (run output is source of exact counts; this audit did not rerun that binary locally).
- The CI checkout commit differs from this exact starting HEAD by the last documented commit boundary. Current HEAD message says documentation-only Tung Chung verification/limitations, but the parent object is unavailable locally, so do not describe CI as an execution on exact `c5c9f11` unless a subsequent run confirms it. CI success is excellent automated evidence, not human playtesting.
- GitHub Actions YAML pins Godot 4.4.1 and official Windows export templates with SHA-512 verification. Workflow downloads from GitHub releases; do not assume every local environment can download it.

## Commands

Run from repository root (after installing Godot 4.4.1 and export templates as appropriate):

```sh
# Import/editor resource scan. Use a working display/driver for GLB preview import.
godot --path . --editor --import
# Or headless import when environment permits.
godot --headless --path . --import

# Main scene startup smoke (120 frames)
godot --headless --path . --quit-after 120

# Automated suites
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/hong_kong_campaign_test.gd
godot --headless --path . --script res://tests/coin_progress_test.gd
godot --headless --path . --script res://tests/npc_route_soak_test.gd
python3 -m unittest discover -s tests -p 'test_*.py' -v

# Windows export (install matching official export templates first)
mkdir -p build/windows
godot --headless --path . --export-release Windows build/windows/PROJECT_ASSASSIN.exe
```

Use `.github/workflows/godot-regression.yml` for authoritative invocation details, Xvfb/Mesa setup, timeouts, visual screenshots and Windows export/launch tests. Export preset name is exactly `Windows`, path `build/windows/PROJECT_ASSASSIN.exe`, export all resources, no embedded PCK. The export output is ignored (`/build/`) and should not be committed. A headless export launch is not interactive Windows testing.

## Known testing limitations

- Test scripts often exercise methods directly or use synthetic input/teleporting; a few physical walk sections are scripted. Some route tests freeze background actors or bypass NPC collision. They do not prove complete human controls, all traversal/collision, visual quality, audio quality or non-deterministic NPC flow.
- Xvfb/Mesa llvmpipe figures and screenshots are synthetic, hardware-specific to CI; not target Iris Xe. No representative target-laptop benchmark or actual human Windows playtest has been performed.
- Windows CI exports and launches scenes headlessly; it cannot certify Windows input/UI/audio/performance.
- The included standalone previews and mission maps are blockouts; visual/cultural review is an explicit human task.

# I. Outstanding development work and known limitations

No risky changes or speculative bug fixes were made during this recovery audit. Distinguish unfinished work from a confirmed reproducible defect.

| Priority / unfinished area | Existing implementation | Missing/limitation and dependencies | Recommended next step |
|---|---|---|---|
| Hong Kong destination scale (~15× target) | Shared original 90×90m city map, three 70×70m fictional neighbourhood extensions, several interiors/ramps/lookouts; station/mountain blocks. | Not a 15× playable destination. Three city missions reuse one blockout; repeated modular stylized geometry, limited routes/space. More content depends on performance budget and actual design requirements. | Establish playable-area definition/target; human-map review and route design; prototype bounded streaming/district sublevels; measure on Iris Xe before populating. |
| Mission narratives/routes | Five ordered missions, target/key/witness/intel/extraction; short linear clues and repeated mission framework. | Story depth/branching/social stealth and substantially distinct routes are sparse; USB mystery intentionally unresolved. | Preserve mandatory/key separation; design authored route variants and mission state data, write test acceptance criteria before expanding. |
| Production character animation | Procedural low-poly person, primitive joints, locomotion and weapon/idle poses; scripted cinematic moves. | No production-quality skinned character models, authored animation clips, facial performance or polished cinematic pipeline. | Art/animation pipeline evaluation; retain collision/stance contracts; replace gradually with retargetable rigs and animation review. |
| Environmental art | Procedural blockout/dressing, nine Kenney CC0 furniture models, two simple shaders. | Major environment-art improvement needed; repeated box geometry, sparse landmarks/details, visual-only props and collision mismatch. | Audit collision/navigation per art pass; culturally grounded reference and original licensed art; keep performance budget explicit. |
| NPC behaviour / navigation | Local deterministic schedules, perception, warnings/reports, basic investigation, short incapacitation and selected nav routes. | No global/group alert model, sophisticated goals/social interaction, robust blocked path recovery, wide obstacle-aware nav, crowd simulation or cross-floor hotel routing. | Build scenario tests for blocked agents and escalation, then bounded behavior-state additions; inspect nav agent recovery in live playtest. |
| Combat and stealth depth | Fictional training pulse, temporary Quiet Line, local disturbance/access/disguise/cover LOS. | No complete combat, health, robust cover, full stealth feedback, tool variety or reliable general AI response. | Keep non-graphic scope; define permitted actions and feedback first; improve detection observability and tests, not just add damage mechanics. |
| Dynamic lighting | Procedural practical lights, shadow toggle/resolution groups, quality presets, view distance. | Lighting is limited/static; lighting changes and visual quality unreviewed; CI indicates MEDIUM/HIGH cost on software-rendered views. | Human visual pass and target hardware measurements; profile before adding dynamic lights/reflections. |
| Audio/music/dialogue | Original synthesized tones, ambience, footfalls; separate buses and controls. | No authored music, spoken Ruby/character dialogue, recordings or human audio review. | Commission/author original assets, record consent/licensing/provenance, map bus routing and test localization/mix. |
| Settings/UI/accessibility | Main menu, tracker, optional objective toggle, loadout, settings, pause/debrief; audio and graphics controls. | Readability/accessibility and keyboard remapping not reviewed; settings height recently caused CI regression (fixed on prior run); no human 720p/1600p test. | Test on real displays/controller/accessibility needs, maintain regression suite and small-screen layout. |
| Campaign/save robustness | Version-1 JSON campaign/settings/checkpoints, `.bak`, migration for completed/partial Initiation and old Meridian completion. | Migration paths are narrow; no user-facing save slots/cloud sync; HK operation checkpoint is specialized; malformed/runtime edge cases remain. | Back up fixture saves, add migration tests before any schema change; keep per-operation isolation and crash-safe writes. |
| Windows/human playtest | Windows CI export and headless scene launches passed at run 43826351110. | No real Windows human route, audio, settings, controller, packaging/anti-virus or target-device testing. | Follow `WINDOWS_PLAYTEST_CHECKLIST.md` with extracted matching artifact and source SHA. |
| Intel Iris Xe performance | CI virtualized llvmpipe metrics and presets. | No actual target FPS, 1% lows, memory, thermals, renderer comparisons or 20–40 NPC stress. | Run repeatable LOW/MEDIUM/HIGH scene routes on powered laptop; record driver, scene, frame-time distribution and memory. |
| Ngong Ping cultural/visual review | Respectful intent and non-interactive scenic Buddha separated from field office/safe; fictional environment. | No local cultural/location expert review, geographic accuracy or landmark visual approval. | Seek informed review before adding detail; treat landmark as public sacred setting, not target/destroyable gameplay. |
| Content architecture | Procedural composition roots and central long scripts work for current tests. | Hotel/HK world scripts mix setup, game state, UI, save/cinematics; maintainability and authoring/iteration cost. | Documented first, then extract a narrow tested service only when required by next feature; avoid broad rewrite during handoff. |
| Testing gaps | Extensive GDScript CI, Python data tests, automated images, Windows export. | Latest local session cannot run Godot; CI exact-run source is parent; no human end-to-end. | Install matching runtime locally or verify fresh CI on current commit; perform interactive human pass before claiming release readiness. |

### Known bugs vs fixed historical failures

No new current-head gameplay bug was independently reproduced in this audit because Godot was unavailable locally. Repository docs record earlier failures fixed before latest green run: settings layout, synthetic cinematic skip/input routing, save/scene compile issues and intermittent station route synchronization. They are historical resolved test issues, not established current bugs. Keep them in regression tests. Potential risks to verify—not claimed confirmed bugs—include HK NPC routing around newly populated interiors/upper rooms, full actor collision during physical train traversal, save/restore around cinematic gates, and quality presets under actual integrated graphics.

# J. New-agent takeover guide

## Setup and run

1. Confirm branch/HEAD and preserve the initial commit identity; inspect `git status`, latest commit and shallow history before modifying. This workspace began clean on `arena/9199c996-stealty-assasin-reimagined-bet` at `c5c9f11d9079ba9c906c520ce25227ffd8476fe7`.
2. Install Godot **4.4.1** and matching official export templates. Open repository `project.godot` in editor and allow import; use graphics/display-compatible import if GLB preview import is failing in dummy renderer. The root entry scene is `scenes/main_menu.tscn`; F5 runs project.
3. In-game, select campaign or mission. Initiation is first; Meridian is optional; Hong Kong missions follow in order. A fresh campaign should not use existing user saves as test data; fixture tests should isolate/restore files.
4. Run Python and Godot suites from section H. For comprehensive CI, use `.github/workflows/godot-regression.yml`; verify exact SHA and current run before citing counts.
5. Windows export uses preset `Windows`, Godot 4.4.1 export template, output `build/windows/PROJECT_ASSASSIN.exe`. Test the complete exported folder (PCK is external) on actual Windows; don't commit generated export.

## Files to read first

- `project.godot`, `export_presets.cfg`, `.github/workflows/godot-regression.yml`
- `README.md`, this handoff, `ARCHITECTURE.md`, `TESTING.md`, `GAMEPLAY.md`
- `scripts/core/campaign_state.gd`, `campaign_progress.gd`, `resources/campaign.json`
- `scripts/world/hotel.gd`, `initiation.gd`, `scripts/missions/hong_kong_operation.gd`
- `resources/hong_kong_operations.json`, mission JSON files
- `scripts/player/player.gd`, `scripts/npc/npc.gd`, `scripts/save/save_store.gd`, `session_snapshot.gd`
- `tests/hong_kong_campaign_test.gd`, `coin_progress_test.gd`, `run_tests.gd`

## Development conventions / preservation rules

- Treat current gameplay, save keys, file paths, IDs, mission order and scene references as contracts until tests prove a safe migration.
- Keep permanent coin progression, temporary coin stock and USB-key progression separate. Keep target completion and physical key pickup separate. Optional witness/intel must not silently gate mandatory extraction.
- Do not replace current scenes with placeholders or delete assets. No save format changes without migration fixtures and test plan. Do not make claims of playability/performance beyond evidence.
- Before altering a world, read its builder and mission JSON; generated visuals may not have collision/navigation. Verify checkpoint bounds after route/environment changes.
- Maintain provenance/license when adding third-party models/audio/fonts; procedural/generated and external asset status must be explicit.
- Avoid one-off fixes that suppress errors or weaken tests. Run Python + broad Godot suite + applicable mission/coin/NPC/visual tests and Windows export when systems change.
- Use current branch only; preserve generated files out of Git (`.godot`, `build`, `visual-test-output`, etc. are ignored).

## Recommended next work (after the audit, by assignment)

1. Ask for and schedule the human Windows/Iris Xe playtest using `WINDOWS_PLAYTEST_CHECKLIST.md`; capture failures and measurements before large art/performance changes.
2. Verify exact-current-HEAD CI and perform an actual human Tung Chung playthrough (contact, dropped key, train doorway, connected carriages, contact exchange, exit, final resolution) with both cinematic skip and no-skip paths.
3. Review Ngong Ping visuals/story with an informed cultural reviewer before expanding its landmark environment.
4. Use real hardware baseline to prioritize city/world scale, NPC navigation and quality settings; avoid implementing a 15× expansion before profiling and a route/content plan.
5. Develop story/route depth and production character/environment/audio content in bounded, independently testable increments.

## Final audit status summary

- **Starting commit:** `c5c9f11d9079ba9c906c520ce25227ffd8476fe7` (branch and parent noted above).
- **Project structure inventoried:** 14 scenes, 41 production scripts, 9 test files, 5 JSON data files, 2 shaders, 9 model files, plus root config/workflow/docs and generated runtime assets.
- **Important source-confirmed systems:** campaign/progression, mission JSON setup, permanent three-lesson rewards, separate five USB keys, save boundary/migration behavior, physical HK target/key gating, tracker Tab/O behavior and independent audio/settings code.
- **Automated evidence:** local 8/8 Python tests; latest available green Godot/Windows CI run 43826351110 on parent SHA `ddf4193…`; not an exact-HEAD local execution.
- **Interactive game:** not run in this environment; no local Godot binary. No human Windows/Iris Xe playtest, audio review or Ngong Ping cultural review.
- **Tung Chung:** source and test coverage confirm a skippable scripted escape, physical dropped key, physical walk-on boarding and connected carriage play, scripted/skippable contact scene, physical final exit and skippable extraction camera. It is not a continuous playable train ride or a distinct external train cinematic.
- **Current blocking known bugs:** none independently confirmed during this audit. Limitations and follow-up test risks are listed in section I.
