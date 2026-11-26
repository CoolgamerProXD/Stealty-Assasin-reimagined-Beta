# Asset provenance and licensing ledger

**Purpose:** source-of-truth ledger for visual-overhaul content. Asset provenance is tracked per item, not inferred from a website's typical policy. The eight Assignment 006 character models below were acquired and converted from pinned CC0 source; CI now confirms Godot 4.4.1 import and outfit/facility test coverage. Campaign-wide visual polish and human acceptance remain in progress; automated asset checks do not establish fit, material quality, or cultural approval.

## Asset acceptance policy

1. Prefer original project-authored geometry/materials or verified CC0/openly licensed resources. Do not rip, extract or republish assets from commercial games, films, maps, photos, or reference images. High-level art-direction research does not license copying.
2. Before importing, record exact asset/item name and version, creator, original source URL, download/source-repository URL and immutable commit or archive/hash, license URL and the license applying to that exact file, required attribution, acquisition date, modifications, destination paths, project use, and reviewer. Save the license text or archived proof alongside the asset when redistribution terms allow; otherwise link the authoritative terms and preserve a dated record.
3. Verify derivatives, embedded textures, fonts, logos, sound and source-model dependencies individually. A pack license does not automatically cover unrelated previews, site branding, third-party dependencies or all content in a mirror.
4. Record generated assets as generated: authoring script/tool/version, inputs, deterministic regeneration command, output dimensions/format, and whether any external input was used. No third-party image may be used as a procedural texture source without its own license entry.
5. Review privacy, cultural representation and trademark/signage concerns independently of copyright. Do not claim the fictional Ngong Ping facility is real.
6. An empty/new ledger entry is a blocking gate, not permission to ship. Re-run asset/license audit after every import and before Windows distribution.

## Existing verified inventory

| Asset set | Creator/source and license | Modification/use | Evidence |
|---|---|---|---|
| Kenney Furniture Kit 2.0 — `bedDouble.glb`, `books.glb`, `chairCushion.glb`, `lampRoundFloor.glb`, `laptop.glb`, `loungeChair.glb`, `loungeSofaLong.glb`, `pottedPlant.glb`, `tableCoffeeGlass.glb` | Kenney, [Furniture Kit 2.0](https://kenney.nl/assets/furniture-kit), CC0 1.0: [license](https://creativecommons.org/publicdomain/zero/1.0/). Files mirror source: `RetroDECK/RetroQUEST`, commit `dfa19a5602a31f64bd890d15279a61f43b127328`, `assets/kenney_furniture-kit/Models/GLTF format/`. Attribution not required; credit is retained. | GLBs unchanged. Project-authored material overrides, placements/scales and separate collisions. | `assets/kenney_furniture/LICENSE.txt`, `assets/kenney_furniture/PROVENANCE.md`, `THIRD_PARTY_ASSETS.md`; the bed GLB Git blob is `1b0efacc4dda050a6abc34974cb692010d29b81c`. |
| Seven Tung Chung procedural 256×256 albedo maps: `tung_chung_tile.png`, `tung_chung_terrazzo.png`, `tung_chung_brushed_metal.png`, `tung_chung_concrete.png`, `tung_chung_rubber.png`, `tung_chung_train_fabric.png`, `tung_chung_warm_wood.png` | Project-authored deterministic patterns, part of PROJECT ASSASSIN. No third-party photos, scans, logos or game assets. | Generated with Python standard-library script `tools/generate_tung_chung_textures.py`; consumed by `scripts/visuals/station_materials.gd`. Albedo patterns, not normal scans/full PBR scan sets. Regenerate with `python3 tools/generate_tung_chung_textures.py`. | `assets/procedural/PROVENANCE.md`, generator source, project repo. |
| MakeHuman-derived CC0 characters: `brad.glb`, `dale.glb`, `ellie.glb`, `gary.glb`, `hollis.glb`, `pickles.glb`, `rosa.glb`, `vance.glb` | HongJaeKIM94 and contributors, RUBBERNECK assets at commit `7c331e647229364f3160790fe158beedf132075a`; upstream identifies these MakeHuman/MPFB outputs as CC0. Source URL: https://github.com/kimhongjae94/rubberneck-assets/tree/7c331e647229364f3160790fe158beedf132075a/models . | Source Meshopt decoded and quantization dequantized using glTF Transform CLI 4.5.1; MikkTSpace tangents generated; embedded WebP converted to PNG and max dimensions limited to 1024 by `tools/convert_makehuman_glb.js`; material alpha changed to mask. | `assets/characters/makehuman_cc0/CC0-1.0.txt`, `SOURCE_ASSETS.md`, `PROVENANCE.md`; deterministic-source selection and build command in `tools/prepare_cc0_characters.sh`. | `StylizedPerson` instantiates the models for player/NPC/cinematic/passenger visuals and role-driven outfit changes; equipment attaches to imported wrists and existing movement/gesture states drive skeleton rotations. CI run [44518105768](https://github.com/CoolgamerProXD/Stealty-Assasin-reimagined-Beta/actions/runs/44518105768) passed Godot 4.4.1 import and automated outfit/facility checks. This does not confirm human-reviewed fit, animation quality, texture/material response, or campaign-wide visual acceptance. |
| Procedural people, outfits, UI, scenery, ambient/effects, campaign environments | Project-authored scripts/primitive geometry, colors and synthesized/project-authored sound; fictional world content. | Runtime-authored materials/geometries and placements; check per-source file for exact implementation. | `ASSETS.md`, `THIRD_PARTY_ASSETS.md`, asset-local provenance files and project scripts. |
| Godot 4.4.1 engine/runtime/export templates | Separate engine dependency, not project artwork. | Windows CI obtains official release and templates and verifies against official SHA-512 list. | `.github/workflows/godot-regression.yml`; [Godot license](https://godotengine.org/license/). |

The existing Kenney and project-authored assets are not evidence that a visual overhaul has passed review. Refer to `ASSETS.md` for campaign additions and caveats.

## Research-only sources (not imported assets)

- [Poly Haven licensing](https://polyhaven.com/license): the site states its downloadable HDRIs, textures and 3D models are CC0, with attribution appreciated but not required. This is not blanket proof for a future file: verify the exact item and keep its item identity/source.
- [ambientCG license](https://docs.ambientcg.com/license/): the site states downloadable assets are CC0 1.0. Verify item provenance and exact downloaded content before use.
- [HITMAN: Codename 47](https://www.ioi.dk/): high-level discussion reference only. No extracted, copied, or derivative game content is authorized or present in this pipeline.
- [Adobe Substance 3D Sampler](https://www.adobe.com/products/substance3d/apps/sampler.html) and Blender/Godot docs informed process research only. Their example images/materials are not game assets.

## New visual-overhaul asset ledger

The eight character models above are the only external assets acquired so far for Assignment 005. No environment, clothing, font, or UI asset packs have been acquired. Add one complete row per further acquired item before use:

| Exact item/file(s) | Creator | Item/source URL | Immutable source/version/hash | Item-specific license + URL | Attribution text/location | Changes/derivatives | In-project path/use | Acquired/reviewed | Notes/dependencies |
|---|---|---|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — | — | — | No new assets yet |

For any new asset pack, also add asset-by-asset entries for embedded textures, materials, models and fonts if license or creator differs. Do not use a placeholder row as a completed review.

## New original/generated assets record

| Asset/output | Authoring source/tool/version | Inputs/provenance | License/ownership | Regeneration | Validation/use |
|---|---|---|---|---|---|
| Character variations and Instinct grade in `scripts/visuals/stylized_person.gd`, `scripts/visuals/instinct_focus.gd` and `.gdshader` | Project-authored GDScript/shader; no external inputs. | Procedural meshes/materials; no external images or textures. | Project-authored source. | Runtime-generated; source is reproducible record. | Godot 4.4.1 CI runtime/render tests pass; no human visual sign-off. |
| Hong Kong facade and sidewalk finishes in `shaders/city_facade.gdshader` and `shaders/city_paving.gdshader` | Project-authored spatial shaders; no external inputs. | Procedural world-space plaster variation, pane rhythm and sidewalk slab wear; no imported textures, scans, photos or maps. | Project-authored source. | Applied at runtime by `scripts/world/landscape_preview.gd`; source is reproducible. | New Assignment 009 work; engine compilation/rendered image review not yet run in this workspace. |
| Hong Kong city/tower details, hotel/annex dressing, role-specific procedural garment additions, and the concealed multi-level Ngong Ping complex | Project-authored procedural geometry/materials in `scripts/world/`, `scripts/visuals/` and `scripts/missions/`; no external photos, game assets or maps. The external human bases remain the pinned CC0 GLBs above. | Generated at runtime by GDScript; collisions/navigation are authored separately from decorative meshes. | Project-authored source distributed with the project. | Code and source data in the repository; no separate binary import. | Facility/wardrobe behavior and 18 staged 1280×720 campaign captures passed CI run `44522902577`; artifact `14528687993`. Human art and cultural review remain outstanding. |

## Audit checklist before merge/release

- [ ] `git status` and asset inventory identify every newly added binary and generated file.
- [ ] Every third-party item has a complete per-item ledger entry and license proof; no “CC0 by site reputation” assumption.
- [ ] `THIRD_PARTY_ASSETS.md` and `ASSETS.md` are synchronized with this ledger.
- [ ] All source/model/texture/font license restrictions permit intended project use, redistribution and modification.
- [ ] No proprietary game/film/reference assets, watermarks, logos or unlicensed real-world maps are present.
- [ ] Imported models/animations/materials pass clean Godot import, Windows export and texture/scale/rig checks.
- [ ] Generated source is deterministic/reproducible or documented as a non-reproducible commissioned deliverable with its rights.
- [ ] Asset provenance is included in the released package or linked in a maintainable, versioned location.
