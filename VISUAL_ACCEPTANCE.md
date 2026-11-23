# Assignment 007 — active visual implementation update (not yet verified)

Updated the Tung Chung campaign station with a gentler cool fill, broader overlapping ceiling practicals, platform screen-door frames and restrained train livery; moved the Meridian restaurant review camera through the actual room opening. The capture harness retains lossless native PNGs, saves native-resolution JPEGs for review/CI transport, writes a manifest, and asks CI to verify dimensions and byte counts. Godot 4.4.1 run [45140609212](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45140609212) passed both jobs and all automated captures. The initial review-image annotations were truncated at 4,096 characters by GitHub's checks API, so that run does **not** provide reconstructed/reviewed native images. A new per-image matrix job splits each native JPEG into bounded chunks for reconstruction; it needs a fresh run. These changes are implementation and automation evidence, not visual sign-off. The older 160×90 images remain quick previews only.

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
- [Run 44522902577](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44522902577), head `bd2a36c`, passed both Windows and headless jobs. The suite reported **25 checks, 0 failures**, including exactly 18 1280×720 captures; full PNGs and 320×180 thumbnails were uploaded in artifact `14528687993`. The sandbox could not download it because the Actions blob host returned `EOF`.
- Follow-up [run 44999624399](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44999624399), head `9f5603b`, passed both jobs and all 18 capture checks. Its 160×90 previews exposed invalid framing: Initiation was staged outside its playable hall; Meridian views were ceiling-heavy; and the station camera was outside the station. I revised those camera positions and labels.
- [Run 45000333659](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45000333659), head `91e06ea`, passed both Windows and headless jobs. The headless suite reported **25 A006 checks, 0 failures**, with exactly 18 views requested at 1280×720 or higher. I recovered and visually inspected all 18 low-resolution (160×90) annotation previews under `screenshots/assignment006/accepted-preview/`. These are supplementary, not the full PNGs. The new views did bring Initiation inside its hall and the station/train inside their playable spaces, but the inspection still found obstructed/ceiling-dominated Meridian interiors, poor station readability, and blocked or uninformative facility/secret-entry views; the small HUD/diagnostic panels also dominate several previews. This is a failing visual review, not acceptance.
- In response, commit `b37a7ab` retargeted Meridian/facility cameras, moved the concealed-entry views to the rear access approach, allowed the opening animation to finish, and hid gameplay CanvasLayers on scenery views while retaining the HUD in gameplay and the Instinct grade layer. [Run 45001019451](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45001019451) passed Linux headless and all 18 capture checks; its Windows job was skipped by the workflow's `[windows]` commit-message condition. Its previews showed less HUD clutter, but the environments remained difficult to judge.
- Commit `c481a9a` made a further camera adjustment. [Run 45001603074](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/45001603074) passed both Windows export/smoke and Linux headless jobs; A006 again reported **25 checks, 0 failures**, with 18 1280×720-or-higher views. I inspected all 18 annotation previews (160×90); the recovered images are preserved in `screenshots/assignment006/review-run-45001603074/`. They are not acceptance-resolution evidence. The train interior and Hong Kong district/harbour frames are legible but distinctly simple, low-poly blockout-like scenes. The revised main Meridian lobby is clearer, but its wing view remains dominated by architectural surfaces; Tung Chung's enclosed station is still very dark. The concealed entrance, monumental interior and central operations previews do not yet read clearly as the intended spaces, and the statue-core view reads mainly as a narrow corridor. This second image review still fails visual sign-off. A final review requires the full-resolution PNGs; Actions artifact download again failed with `EOF`.

| View | 160×90 preview observation (not sign-off) |
|---|---|
| 01 Initiation assessment hall | Correct playable interior; broad gray floor dominates and architecture reads as a sparse prototype. |
| 02 Initiation player/NPC | Characters are present, but the same flat gray hall and small figures limit visual readability. |
| 03 Meridian main environment | Lobby layout is clearer after retargeting, though materials/furnishing remain sparse and flat. |
| 04 Meridian interior lighting | Beam/ceiling and wall surfaces still dominate; the intended room/lighting is not legible. |
| 05 Tung Chung station | Enclosed station composition is valid but too dark to assess its layout or finish. |
| 06 Train interior | Playable carriage and aisle are readable; detail and material richness remain modest. |
| 07 Hong Kong streets | Street/storefront is visible but blocky; a foreground pole bisects the composition. |
| 08 Commercial district | Building massing is visible but pale and simple; foreground obstruction weakens the view. |
| 09 Harbour skyline | Skyline/harbour are recognizable, but the scene is sparse and distant. |
| 10 Characters/disguise | Player and NPC outfit contrast is visible; presentation remains low-detail and staged. |
| 11 Ngong Ping exterior | Landmark is centered and recognizable in the stylized scene; cultural review is still required. |
| 12 Discovered facility entrance | Door/access route remains too small and indistinct to verify discovery presentation. |
| 13 Facility monumental interior | Interior contents are faint/unclear; the frame does not communicate a monumental hall. |
| 14 Central operations | Command-table silhouette is present, but the room and its consoles are too dim/unclear. |
| 15 Statue core | Reads mainly as a narrow corridor, not a clear vertical interior. |
| 16 Instinct target/intel | Markers are small and difficult to distinguish at thumbnail scale. |
| 17 Undiscovered secret | Closed-state access seam is not clearly visible; secret-state contrast is unproven. |
| 18 Campaign HUD gameplay | HUD is present, but the view is dark and still needs high-resolution UI/readability review. |
- The repository's other prior annotation previews include `hk_play_ngong_ping.jpg` (a very simplified green low-poly landmark approach) and `hk_skyscraper_interior.jpg` (sparse, flat, angular geometry). They reinforce that scene rendering is not equivalent to the grounded, materially rich campaign finish requested. No equivalent-condition old/new baseline comparison or high-resolution reviewer sign-off exists.

## Human playtest, culture and target-device gates

- No continuous human interactive playthrough of every campaign mission, disguise transition, save/checkpoint, Instinct discovery state and secret facility is recorded. Existing CI tests are scripted/staged and some freeze background NPCs or position actors/cameras directly.
- No cultural/community review of the Tian Tan Big Buddha representation or fictional facility premise is recorded. Preserve the separate, intact public landmark and seek appropriate review before calling the depiction respectful/approved.
- No measurement was made on Windows 11 / i5-1335U / 16 GB / Intel Iris Xe at 1280×720. Linux Xvfb/Mesa figures in `PERFORMANCE.md` are hosted software-renderer measurements, not Iris Xe performance.

## Remaining acceptance work

1. Retrieve and review all 18 full-resolution PNGs at useful scale, then correct the remaining Meridian, station and facility readability/framing issues. Record image-by-image readability, misses, visual defects and required changes; the CI count and 160×90 previews alone are not a quality review.
2. Establish the required equivalent-condition before/after set (same camera, lighting/exposure, character state, renderer and preset) for the requested scenarios. Current scripted views alone are not before/after evidence.
3. Continue the campaign-wide environment, garment/material, dynamic-lighting and UI polish until actual images meet the stated direction; do not substitute asset/model presence for scene quality.
4. Conduct and record interactive playtesting and appropriate cultural/landmark review when possible.
5. Run an honest Windows export and target-device performance pass on the specified machine if accessible; otherwise mark those gates unverified.
6. Update the six required project documents with final verified outcomes, commit/push to the active branch, and leave a clean worktree.

Until then, assignment completion remains blocked. Do not fabricate visual approval, playtesting, target-device measurements, or capture success.
