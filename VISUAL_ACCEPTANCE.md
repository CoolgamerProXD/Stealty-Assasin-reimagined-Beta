# Assignment 006 visual acceptance report

**Status: INCOMPLETE — no campaign-wide art sign-off.** This report distinguishes Godot import/functional automation, staged screenshots, and human visual/device review. None are interchangeable. The current bar is the `ART_DIRECTION.md` and `RENDERING_PIPELINE.md` gate set; a passing engine test alone is not acceptance.

## Verified implementation and regressions

- Eight pinned MakeHuman/MPFB-derived CC0 GLBs are integrated through `StylizedPerson` for player, NPC, cinematic and passenger scenes. Role/outfit selection, garment materials, bone-driven movement/gestures, equipment attachments and fully covered clothing recovery are implemented. Godot 4.4.1 CI run [44518105768](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44518105768) passed both Windows and headless jobs; the headless disguise/facility suite asserted imported player/NPC models, outfit changes, equipment attachment and clothing coverage. This is automated runtime evidence, not animation/fit/material acceptance.
- The same run passed the integrated Hong Kong campaign, target/key/progression tests, NPC route cycles, camera/display, rendered Instinct and existing cinematic/environment capture suites. It also passed Windows import/export and headless executable smoke. It is not an interactive Windows playthrough or target-machine test.
- The multi-level Ngong Ping facility is collision-backed in code and tested as connected subterranean floors and chambers within the recognizable landmark shell. Its rear entrance is mission-discovery gated; the separate field archive contains Key 05. `tests/disguise_facility_test.gd` passed route and discovery checks in run 44518105768. This does not constitute cultural/community review.
- The city, skyscraper, hotel, station/train and mountain changes are procedural/GDScript work; no commercial game assets were copied. Pinned sources and conversion steps are recorded in `ASSET_PROVENANCE.md` and `assets/characters/makehuman_cc0/PROVENANCE.md`.

## Scripted images and visual inspection

- The repository now contains `tests/assignment006_visual_acceptance.gd`, which requests 18 real Godot scene captures at 1280×720 spanning Initiation, Meridian, Tung Chung/station/train, Hong Kong's districts/harbour/disguise, Ngong Ping's public exterior and discovered entry, underground and statue-core spaces, target/intel Instinct and gameplay HUD. The CI job writes PNGs and small review JPEGs to an `assignment006-visual-acceptance` artifact.
- The initial capture run [44520489133](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44520489133) failed its new capture step. Direct diagnostic annotations on [44521725323](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44521725323) showed two fixture errors: the test selected the wrong NPC for a market disguise and tried to hide an already-open one-way facility door. It now selects/sets the market-vendor NPC explicitly and captures the sealed, undiscovered state before opening the panel.
- Latest verified run [44522902577](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta), head `bd2a36c8003024f081840ead5938f2c7fb868baf`, passed both Windows and headless jobs. The acceptance script reports **25 checks, 0 failures**, including a counter asserting exactly **18** distinct in-game captures at 1280×720. PNGs and 320×180 review thumbnails were uploaded in [artifact 14528687993](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44522902577/artifacts/14528687993), 3.4 MB. The sandbox could not download the artifact because the Actions blob host returned `EOF`; the artifact is available from the linked run. A follow-up workflow revision will expose reduced annotation previews, but those lower-resolution images still cannot replace reviewing the full PNGs.
- Partial annotation-recovered previews from the earlier successful CI run are under `screenshots/assignment006/ci/`. I visually inspected examples: `hk_play_ngong_ping.jpg` depicts a very simplified green low-poly approach to the landmark; `hk_skyscraper_interior.jpg` depicts a sparse, flat, angular interior. They establish that scenes rendered, but also show that the environments still read as blockout/prototype geometry rather than the grounded, materially rich campaign finish requested. One lobby thumbnail is truncated/invalid. These small previews are not the 18-view suite and cannot support a final-quality claim.
- A complete **automated** set of 18 distinct 1280×720 screenshots is confirmed in the passing run's Actions artifact, but the sandbox could not retrieve its PNGs for review and none has human sign-off. The small annotation-recovered older CI thumbnails are not from this 18-view set. There is no equivalent-condition old/new baseline comparison or high-resolution reviewer-approved evidence; these captures are not described as artistic acceptance.

## Human playtest, culture and target-device gates

- No continuous human interactive playthrough of every campaign mission, disguise transition, save/checkpoint, Instinct discovery state and secret facility is recorded. Existing CI tests are scripted/staged and some freeze background NPCs or position actors/cameras directly.
- No cultural/community review of the Tian Tan Big Buddha representation or fictional facility premise is recorded. Preserve the separate, intact public landmark and seek appropriate review before calling the depiction respectful/approved.
- No measurement was made on Windows 11 / i5-1335U / 16 GB / Intel Iris Xe at 1280×720. Linux Xvfb/Mesa figures in `PERFORMANCE.md` are hosted software-renderer measurements, not Iris Xe performance.

## Remaining acceptance work

1. Retrieve and review the passing run's 18 full-resolution PNGs at useful scale. Record image-by-image readability, misses, visual defects and required changes; the CI count alone is not a quality review.
2. Establish the required equivalent-condition before/after set (same camera, lighting/exposure, character state, renderer and preset) for the requested scenarios. Current scripted views alone are not before/after evidence.
3. Continue the campaign-wide environment, garment/material, dynamic-lighting and UI polish until actual images meet the stated direction; do not substitute asset/model presence for scene quality.
4. Conduct and record interactive playtesting and appropriate cultural/landmark review when possible.
5. Run an honest Windows export and target-device performance pass on the specified machine if accessible; otherwise mark those gates unverified.
6. Update the six required project documents with final verified outcomes, commit/push to the active branch, and leave a clean worktree.

Until then, assignment completion remains blocked. Do not fabricate visual approval, playtesting, target-device measurements, or capture success.
