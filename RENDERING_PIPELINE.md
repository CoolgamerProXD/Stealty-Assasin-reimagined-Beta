# Rendering and visual production pipeline

**Status:** active, incomplete Assignment 006 implementation. Baseline is Godot 4.4.1, GL Compatibility, 1280×720. The campaign uses eight provenance-recorded CC0 skinned character models, role/outfit swaps, bone-driven motion, hand equipment, and a discovery-gated Instinct grade; multi-level Ngong Ping facility and campaign environments are implemented in existing scenes. CI run [44518105768](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44518105768) passed Godot import, export and gameplay/disguise/facility checks. The recovered selected CI thumbnails remain visually simple/stylized and are not an art sign-off. The 18-view genuine-scene capture suite passed 25 checks and captured 18 images in CI run [44522902577](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44522902577), with full PNGs in artifact `14528687993`; the sandbox could not retrieve that artifact for image-by-image review. No approved old/new comparison, human visual review, interactive playthrough, cultural review or Windows/Iris Xe target benchmark is established. Renderer choice remains Compatibility for portability, not because it won target-device comparison.

## Non-negotiable integration rules

- Mission/gameplay data is the authority for discovery, interaction, disguise, NPC role, target completion, and save state. A rendering layer only presents that state; it must not grant or reveal gameplay information.
- Preserve movement, collision, Navigation/AI, disguise permissions and persistence, mission progression, save/load, interaction ranges, target discovery, existing outfit IDs, and fully covering civilian underwear. Visual state must restore correctly after save/load and scene transitions.
- Keep art and rendering changes staged, reviewable and reversible. No broad random material edits. Capture the unchanged baseline before modifying each scene family.
- Use only project-authored/procedural or item-verified licensed assets. Update provenance at acquisition/import time. Do not extract or imitate proprietary assets.
- Do not switch the default renderer or enable expensive effects without controlled target-hardware measurements and a fallback review.

## Phased implementation

### 0 — Baseline inventory and reproducibility

1. Record branch/commit, Godot version, project renderer, viewport, preset, machine, scene, camera transform, population and gameplay state.
2. Capture all baseline shots in the acceptance matrix below from a release-like build with fixed camera/player coordinates, time of day, exposure, quality preset and NPC/mission state. Store lossless PNGs under `docs/visual_evidence/before/` (or an equivalent documented location) with metadata. Do not overwrite the baseline.
3. Run current headless/gameplay tests and Windows export/smoke workflow. Record known warnings and current performance; historical llvmpipe figures stay labeled software-only.
4. Compare Compatibility, Mobile and Forward+ on the target machine using a minimal representative scene before renderer-dependent work. Record feature gaps, stability and exact settings. If target hardware is unavailable, mark the decision open and continue only with portable work.

### 1 — Shared material, color and light foundation

1. Create a small reusable palette/material library for paint, concrete, stone, tile, wood, fabric, rubber, glass and metal. Use `StandardMaterial3D`/ORM where possible; use original repeatable procedural maps only where visible at 720p.
2. Establish neutral exposure/tonemapping, world fill and location lighting conventions. Test colors/roughness under neutral/warm/cool sources and both Instinct states.
3. Use a restrained hybrid: a small number of deliberate dynamic lights, static/baked GI only for suitable fixed scenes, optional ReflectionProbe `Once` after inspection, selective shadows. Keep Compatibility feature limits in mind.
4. Apply materials to one small approved environment slice and inspect for incorrect gamma/data channels, tiling, UV stretching, mesh seams, dark/light leaks and role/readability losses before reuse.

### 2 — Character and wardrobe foundation

1. Freeze current public gameplay API (`set_role`, `set_outfit`, outfit IDs, role permissions, wardrobe interactions, save state) and create test fixtures for each existing occupation/disguise plus fully covering underwear.
2. Prototype a reusable human base with genuinely human body/face/hair/footwear and garment silhouettes. If sourcing a rigged glTF asset, record item-specific license/creator/source/modifications and verify import, rig/bone rest, materials, texture sizes, animation and collision separation first.
3. Keep body/face variation orthogonal to role/outfit. Use shared materials and deterministic variation; avoid identical cloned silhouettes, but do not permit variation to obscure identity or role cues.
4. Validate animation poses and garment intersections, weapon/tool attachments, camera distances, disguise transitions, outfit persistence and civilian coverage before migrating any crowd.
5. Batch/migrate by campaign scene only after prototype acceptance. Keep a rollback path to the prior procedural figure until each scene is validated.

### 3 — Campaign environment passes

For each family—station/transit, hotel, commercial/market/harbour, Ngong Ping public environs, fictional facility, city/mountain previews and remaining campaign scenes—work in this order:

1. geometry/silhouette and correct scale; 2. navigation/collision/sightline integrity; 3. material assignment; 4. key/fill/practical lighting; 5. broad architectural variation; 6. near-field props/wear/signage; 7. selective far-detail/LOD/instancing; 8. same-camera capture and visual inspection; 9. gameplay regression and performance profile.

Do not claim a campaign-wide pass until all campaign scenes have been inventoried and captured. Check Ngong Ping cultural context separately; the secret facility is explicitly fictional.

### 4 — Instinct focus effect

1. Preserve mission code eligibility and current specific exceptions. Audit all target/item/key/intel/disguise markers across mission families before changing shared behavior.
2. Add a single full-screen, renderer-compatible screen-texture grade controlled by the existing held Instinct state: smooth ramp, moderate chroma reduction and slight value/contrast shaping, no scene color replacement, no HUD grade. The exact shader must be validated in the chosen renderer.
3. Keep object overlays per the existing mission permission/discovery/view/range/used/completion rules. Do not use depth buffer hacks or generic object scanning. A shader cannot identify a hidden eligible object.
4. Test press, hold, release, pause/focus loss, scene transition, completion state, occlusion and HUD; test undiscovered secrets remain absent. Smoothness must not add latent highlight or alter gameplay timing.

### 5 — Optimization, target measurement and closeout

1. Profile the same fixed views and actual interactive route with LOW/MEDIUM/HIGH presets; record frame times and memory after warmup. Keep texture/mesh loading and first-use shader hitches separate from steady state.
2. Inspect draw calls/visible geometry where available. Add batching, LOD, visibility/occlusion or shadow reductions only with image and CPU/GPU profiling evidence. Never remove collision/AI or mission cues to improve a visual-only benchmark.
3. Run full Godot 4.4.1 CI, Windows export/smoke, headless tests and all gameplay regression suites. Capture warnings/errors. Repeat visual matrix after final integration.
4. Have a human reviewer inspect old/new captures at equal conditions and perform an interactive playtest. Record these separately from automation. Measure the Windows target if available; otherwise explicitly say not measured.
5. Write final results and limitations to `VISUAL_ACCEPTANCE.md` (or update this document): scene coverage, pass/fail per criterion, evidence paths, test run IDs/commit, reviewer/playtest status, exact benchmark conditions, unresolved gaps and follow-up budget.

## Renderer and effect selection gate

The default remains current Compatibility until comparative results decide otherwise. Test each viable renderer on Windows target hardware because feature compatibility and driver performance differ. Record per renderer: engine/version, build type, API/driver/GPU, resolution, VSync/frame cap, preset, camera/route/population, shader warmup, 60+ second sample, average/median and p95/p99 frame time, memory and stability. Compare image captures as well as numbers. Keep Compatibility fallback behavior valid. No desktop Linux software renderer is evidence for Iris Xe throughput.

## Asset import and material validation

- Preferred scene interchange for rigged characters: glTF 2.0. Confirm transforms, scale/orientation, bone names/rest, skin weights, animation clips, material channels, alpha mode, texture color space, normal convention and draw-call/material count in the Godot import preview.
- Albedo/base color is color data; roughness, metallic, AO and normal are linear/data textures as appropriate. Validate ORM channel packing and normal-map direction using known test lighting.
- Check real scale against a player reference, mesh bounds/origin, collision proxy, shadow casting, UVs/tangents, texture filtering/mipmaps, compression and max resolution. Keep material count low where appropriate.
- Model source/high-resolution work is not automatically runtime work: optimize geometry/textures for 720p and target memory. Any LOD/occlusion/lightmap need scene-specific visual comparison and import settings committed in source control.
- Avoid alpha-blended cloth/hair where opaque/alpha-scissor geometry suffices; sort and shadow implications matter.
- All imported external files need item-specific provenance before merge. CI must import/export them successfully from a clean checkout.

## Proposed capture matrix (18 comparable views)

Each numbered entry is one old/new paired capture with identical camera, resolution, preset, lighting/time, player pose, population and mission/discovery state. Capture without UI clutter where the UI is not under review, then capture the relevant HUD state separately. This is a practical project-defined matrix to ensure broad coverage; if the user supplied a different named list, reconcile before sign-off rather than claiming these are their exact names.

| ID | Campaign scenario | Framing/state | Primary inspection |
|---|---|---|---|
| V01 | Main menu | default composition | hierarchy, background, typography/readability |
| V02 | Initiation | opening/player view | environment tone, player/target readability |
| V03 | Hotel | exterior arrival | architecture, glass, facade and daylight |
| V04 | Hotel | lobby wide | material/light coherence, furniture and sightlines |
| V05 | Hotel | guest room close | cloth/wood/metal detail, human-scale props |
| V06 | Hotel | corridor | repetition, lighting pools, occlusion and navigation |
| V07 | Hotel | NPC group | human diversity, outfit silhouette and animation |
| V08 | Hotel | disguise/wardrobe state | role identity and fully covered underwear invariant |
| V09 | Tung Chung | station concourse | tile/terrazzo/metal/fabric PBR consistency |
| V10 | Tung Chung | train interior | seats, handrails, signage and lighting |
| V11 | Hong Kong district | market street | layered facades, signs, crowd and color rhythm |
| V12 | Hong Kong district | commercial plaza/tower | scale, glazing, vertical composition and reflections |
| V13 | Harbour | waterfront street | water/edge, silhouettes, haze and light hierarchy |
| V14 | Ngong Ping | public exterior/landmark view | respectful fictional presentation, scale and daylight |
| V15 | Ngong Ping | concealed facility entrance | secret visibility remains gated; route readability |
| V16 | Facility | interior corridor/lab | coherent fictional industrial kit, signs and shadows |
| V17 | Instinct | eligible visible target/item | graded environment, contextual/discovery-gated overlays |
| V18 | Instinct | undiscovered/occluded secret test | nothing secret/unknown leaks; compare normal vs focus |

For each pair save baseline and candidate lossless images and metadata. A pixel diff may help locate changes but cannot replace human inspection. Store target-device screenshots separately from CI captures. Never substitute a renderer screenshot from CI for target hardware evidence.

## Evidence and reporting vocabulary

- **Automation:** exact CI workflow/run, automated assertions and exit status.
- **Headless/gameplay regression:** tests that exercise mission, disguise, NPC, save and navigation logic; not a visual judgment.
- **Human visual review:** reviewer, date, machine/renderer and reviewed evidence set; list issues rather than using an unsupported “looks good.”
- **Interactive playtest:** participant/task, route, duration, issues; separate from a scripted smoke test.
- **Target-hardware benchmark:** exact device/OS/GPU driver/build/renderer/preset/resolution/route and frame-time/memory data. Not available unless actually run.
- **Completion:** requires all 18 paired captures, reviewed campaign coverage, tested gameplay invariants, successful full CI/export, target measurement or explicit unmeasured disclosure, and no unresolved blocking visual/gameplay/performance issue. Any missing gate means partial/incomplete.
