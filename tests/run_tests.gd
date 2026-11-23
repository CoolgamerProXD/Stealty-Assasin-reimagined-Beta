extends SceneTree

var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
 call_deferred("run")

func check(condition: bool, description: String) -> void:
 checks += 1
 if condition:
  print("PASS: ", description)
 else:
  failures.append(description)
  printerr("FAIL: ", description)

# Measure the low point directly from the rendered shoe transform, independent
# of the character's own procedural contact calculation.
func shoe_bottom(shoe: MeshInstance3D) -> float:
 var basis := shoe.global_transform.basis
 var vertical_radius := 0.5 * sqrt(basis.x.y * basis.x.y + basis.y.y * basis.y.y + basis.z.y * basis.z.y)
 return shoe.global_position.y - vertical_radius

func run() -> void:
 var settings_service: Node = root.get_node("Campaign")
 var settings_backup: Dictionary = settings_service.settings.duplicate(true)
 var settings_path_backup: String = settings_service.settings_path
 var isolated_settings := "user://assassin_settings_test_%d.json" % Time.get_ticks_usec()
 settings_service.settings_path = isolated_settings
 for quality: String in ["LOW", "MEDIUM", "HIGH"]:
  settings_service.settings["graphics"] = quality
  settings_service.settings["show_fps"] = true
  check(settings_service.save_settings(), quality + " graphics settings save")
  var scale: float = root.scaling_3d_scale
  check(is_equal_approx(scale, 0.7 if quality == "LOW" else (0.85 if quality == "MEDIUM" else 1.0)), quality + " applies viewport render scale")
  settings_service.settings["graphics"] = "MEDIUM"
  settings_service.settings["show_fps"] = false
  settings_service._load_settings()
  check(settings_service.settings["graphics"] == quality and settings_service.settings["show_fps"], quality + " and FPS setting persist")
 var master_bus := AudioServer.get_bus_index("Master")
 settings_service.settings["volume"] = 0.0
 settings_service.apply_settings()
 check(master_bus >= 0 and AudioServer.is_bus_mute(master_bus), "zero volume mutes the master bus")
 settings_service.settings["volume"] = 0.5
 settings_service.apply_settings()
 check(master_bus >= 0 and not AudioServer.is_bus_mute(master_bus), "raising volume unmutes the master bus")
 for entry: Array in [["Music", "music_volume", 0.25], ["SFX", "sfx_volume", 0.5], ["Ambient", "ambient_volume", 0.75], ["Dialogue", "dialogue_volume", 0.0]]:
  settings_service.settings[entry[1]] = entry[2]
 check(settings_service.save_settings(), "independent audio levels save")
 for entry: Array in [["Music", "music_volume", 0.25], ["SFX", "sfx_volume", 0.5], ["Ambient", "ambient_volume", 0.75], ["Dialogue", "dialogue_volume", 0.0]]:
  var bus := AudioServer.get_bus_index(entry[0])
  check(bus >= 0 and AudioServer.get_bus_send(bus) == "Master" and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(bus)), maxf(0.001, float(entry[2]))) and AudioServer.is_bus_mute(bus) == (entry[2] == 0.0), str(entry[0]) + " bus routes to Master with independent live level")
  settings_service.settings[entry[1]] = 1.0
 settings_service._load_settings()
 check(is_equal_approx(settings_service.settings["music_volume"], 0.25) and is_equal_approx(settings_service.settings["sfx_volume"], 0.5) and is_equal_approx(settings_service.settings["ambient_volume"], 0.75) and is_equal_approx(settings_service.settings["dialogue_volume"], 0.0), "all audio levels persist")
 # Legacy files contain only master volume; the category defaults are neutral.
 SaveStore.write(isolated_settings, {"volume": 0.4})
 settings_service._load_settings()
 check(is_equal_approx(settings_service.settings["volume"], 0.4) and is_equal_approx(settings_service.settings["music_volume"], 1.0) and is_equal_approx(settings_service.settings["dialogue_volume"], 1.0), "legacy master-only settings migrate without reducing categories")
 settings_service.settings = settings_backup
 settings_service.settings_path = settings_path_backup
 settings_service.apply_settings()
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(isolated_settings + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(isolated_settings + suffix))
 check(AccessRules.can_enter("visitor", "public"), "visitor may enter public")
 check(not AccessRules.can_enter("visitor", "staff"), "visitor denied staff")
 check(AccessRules.can_enter("staff", "staff"), "staff granted staff")
 check(not AccessRules.can_enter("staff", "secure"), "staff denied secure")
 check(not AccessRules.can_enter("manager", "unknown"), "unknown areas fail closed")
 var bag := Inventory.new()
 bag.capacity = 1
 check(bag.add("ledger") and bag.has_item("ledger"), "inventory stores item")
 check(not bag.add("ledger") and not bag.add("memo"), "inventory rejects duplicate and overflow")
 var mission := Mission.new()
 var definition: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://resources/meridian_mission.json"))
 check(not mission.configure(null) and not mission.can_extract(), "missing mission configuration fails closed")
 check(not mission.configure({"records": [], "required_records": 2}), "empty mission configuration rejected")
 var invalid: Dictionary = definition.duplicate(true)
 invalid["records"][1]["id"] = invalid["records"][0]["id"]
 check(not mission.configure(invalid), "duplicate configured IDs rejected")
 invalid = definition.duplicate(true)
 invalid["required_records"] = 4
 check(not mission.configure(invalid), "impossible requirement rejected")
 invalid = definition.duplicate(true)
 invalid["records"][0]["position"] = [0, "invalid", 0]
 check(not mission.configure(invalid), "invalid record position rejected")
 check(mission.configure(definition) and mission.available_records.size() == 3 and mission.required_records == 2, "mission config defines three records and requires two")
 check(not mission.record_clue("unknown"), "unconfigured record rejected")
 check(mission.record_clue("ledger") and not mission.record_clue("ledger"), "duplicate clue cannot be recorded")
 check(not mission.extract(), "one unique clue cannot unlock extraction")
 check(mission.record_clue("memo") and not mission.extract(), "two clues alone cannot replace the target objective")
 check(mission.mark_action("interview_ivo") and not mission.extract(), "witness and records alone do not satisfy the primary target")
 check(mission.set_target_temporary_incapacitation("adrian_locke", true) and not mission.can_extract() and mission.objective_text().contains("temporarily incapacitated"), "temporary primary-target incapacitation stays visible as non-complete objective state")
 check(mission.target_temporarily_incapacitated and mission.set_target_temporary_incapacitation("adrian_locke", false) and not mission.target_temporarily_incapacitated, "recovering primary target clears only temporary state")
 var target_events := [0]
 mission.changed.connect(func() -> void: target_events[0] += 1)
 var first_target := mission.mark_target("adrian_locke")
 var duplicate_target := mission.mark_target("adrian_locke")
 check(first_target and not duplicate_target and target_events[0] == 1, "target completion emits exactly one change")
 check(mission.extract() and mission.extracted and not mission.extract(), "target, witness and records unlock extraction")
 check(mission.record_clue("archive") and mission.progress_text().contains("3 / 3") and mission.progress_text().contains("Required: 2"), "progress distinguishes available and required after third clue")
 var memory := NpcMemory.new()
 memory.retention_seconds = 2.0
 memory.observe("trespass", Vector3.ONE)
 memory.tick(1.0)
 check(memory.observations.size() == 1 and memory.observations[0]["source"] == "direct", "memory retains direct observation")
 memory.tick(1.1)
 check(memory.observations.is_empty(), "memory expires")
 var save_path := "user://assassin_test_store_%d.json" % Time.get_ticks_usec()
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(save_path + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path + suffix))
 check(SaveStore.write(save_path, {"clues": ["ledger"]}), "write versioned save")
 check(SaveStore.read(save_path).get("clues", []) == ["ledger"], "read versioned save")
 check(SaveStore.write(save_path, {"clues": ["memo"]}), "replace save and keep backup")
 var corrupt := FileAccess.open(save_path, FileAccess.WRITE)
 corrupt.store_string("not json")
 corrupt.close()
 check(SaveStore.read(save_path).get("clues", []) == ["ledger"], "corrupt save falls back to backup")
 check(SaveStore.write(save_path, {"clues": ["archive"]}), "write after primary corruption")
 corrupt = FileAccess.open(save_path, FileAccess.WRITE)
 corrupt.store_string("not json")
 corrupt.close()
 check(SaveStore.read(save_path).get("clues", []) == ["ledger"], "writing after corruption preserves good backup")
 var incompatible := FileAccess.open(save_path + ".bak", FileAccess.WRITE)
 incompatible.store_string(JSON.stringify({"version": 999, "data": {"clues": ["memo"]}}))
 incompatible.close()
 check(SaveStore.read(save_path).is_empty(), "unsupported save version is rejected")
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(save_path + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path + suffix))
 check(SaveStore.read(save_path).is_empty(), "missing save handled")
 var scene: PackedScene = load("res://scenes/hotel.tscn")
 var world: Node = scene.instantiate()
 root.add_child(world)
 await process_frame
 await physics_frame
 var player: HotelPlayer = world.get("player")
 var fine_detail: MultiMeshInstance3D = world.get_node("EnvironmentDressing/FineDetail")
 var practicals := get_nodes_in_group("quality_practicals")
 var old_quality: String = settings_service.settings["graphics"]
 settings_service.settings["graphics"] = "LOW"
 settings_service.apply_settings()
 check(not fine_detail.visible and practicals.size() > 0 and not (practicals[0] as Light3D).visible, "LOW hides fine decoration and practical lights")
 settings_service.settings["graphics"] = "MEDIUM"
 settings_service.apply_settings()
 check(not fine_detail.visible and (practicals[0] as Light3D).visible, "MEDIUM enables practical lights")
 settings_service.settings["graphics"] = "HIGH"
 settings_service.apply_settings()
 check(fine_detail.visible and (practicals[0] as Light3D).visible, "HIGH enables fine decoration and practical lights")
 settings_service.settings["shadows"] = false
 settings_service.settings["practicals"] = false
 settings_service.apply_settings()
 var sun_lights := get_nodes_in_group("quality_lights")
 check(not (practicals[0] as Light3D).visible and not (sun_lights[0] as Light3D).shadow_enabled, "lighting overrides disable practicals and shadows without restart")
 settings_service.settings["long_view"] = false
 settings_service.apply_settings()
 check(is_equal_approx(player.camera.far, 75.0), "view distance applies to the live player camera")
 settings_service.settings["long_view"] = true
 settings_service.apply_settings()
 check(is_equal_approx(player.camera.far, 220.0), "long view restores without restarting")
 settings_service.settings["shadows"] = true
 settings_service.settings["practicals"] = true
 settings_service.settings["graphics"] = old_quality
 settings_service.apply_settings()
 var npcs: Array[HotelNpc] = world.get("npcs")
 check(player != null and npcs.size() == 7, "hotel preserves existing NPCs and adds three wing visitors")
 var first_leg_mesh: Mesh = (npcs[0].person.left_leg.get_child(0) as MeshInstance3D).mesh
 var second_leg_mesh: Mesh = (npcs[1].person.left_leg.get_child(0) as MeshInstance3D).mesh
 check(first_leg_mesh == second_leg_mesh and npcs[0].person.torso.mesh == npcs[1].person.torso.mesh, "identical character primitives share immutable mesh resources")
 check(npcs[0].person.clothing != npcs[1].person.clothing, "shared character meshes retain independent clothing materials")
 var gait_figure := StylizedPerson.new()
 world.add_child(gait_figure)
 var maximum_float := 0.0
 var maximum_sink := 0.0
 for frame: int in range(180):
  gait_figure.animate_motion(1.0 / 60.0, 3.8)
  if frame > 30:
   var low_foot := minf(shoe_bottom(gait_figure.left_knee.get_child(1) as MeshInstance3D), shoe_bottom(gait_figure.right_knee.get_child(1) as MeshInstance3D))
   maximum_float = maxf(maximum_float, low_foot)
   maximum_sink = maxf(maximum_sink, -low_foot)
 print("GAIT_DIAG: float=", maximum_float, " sink=", maximum_sink)
 check(maximum_float < 0.035 and maximum_sink < 0.035, "procedural running stride keeps a shoe near the ground plane")
 gait_figure.crouch_amount = 1.0
 maximum_float = 0.0
 maximum_sink = 0.0
 for frame: int in range(180):
  gait_figure.animate_motion(1.0 / 60.0, 1.5)
  if frame > 30:
   var low_foot := minf(shoe_bottom(gait_figure.left_knee.get_child(1) as MeshInstance3D), shoe_bottom(gait_figure.right_knee.get_child(1) as MeshInstance3D))
   maximum_float = maxf(maximum_float, low_foot)
   maximum_sink = maxf(maximum_sink, -low_foot)
 print("GAIT_DIAG: crouch float=", maximum_float, " sink=", maximum_sink)
 check(maximum_float < 0.035 and maximum_sink < 0.035, "procedural crouch gait keeps a shoe near the ground plane")
 gait_figure.queue_free()
 check(str(world.call("footstep_surface", Vector3(-25,0,-2))) == "carpet" and str(world.call("footstep_surface", Vector3(-25,0,-10))) == "wood", "hotel chooses footstep surfaces from local flooring")
 var furniture := world.get_node_or_null("EnvironmentDressing/HotelFurniture")
 check(furniture != null and furniture.get_child_count() >= 20, "Meridian instantiates authored seating, lamps and plants")
 var crockery := world.find_child("DiningCrockery", true, false) as MultiMeshInstance3D
 check(crockery != null and crockery.multimesh.instance_count == 24, "restaurant has batched round plates and cups")
 var dining_lights := get_nodes_in_group("dining_practicals")
 check(dining_lights.size() == 2 and (dining_lights[0] as OmniLight3D).omni_range >= 8.0, "restaurant has two dedicated shadowless light pools")
 await physics_frame
 var furniture_query := PhysicsRayQueryParameters3D.create(Vector3(-38,0.5,-7.5), Vector3(-38,0.5,-8.45))
 var furniture_hit := player.get_world_3d().direct_space_state.intersect_ray(furniture_query)
 check(not furniture_hit.is_empty() and (furniture_hit.collider as Node).is_in_group("new_furniture_collision"), "restaurant chair blocks physical movement")
 var all_chairs_aligned := true
 for table_x: float in [-38.0,-31.0,-24.0,-17.0]:
  for chair_z: float in [-11.55,-8.45]:
   var visual_found := false
   for holder: Node in furniture.get_children():
    if holder is Node3D and holder.position.distance_to(Vector3(table_x,0,chair_z)) < 0.01: visual_found = true
   var chair_start := Vector3(table_x,0.5,chair_z + (-0.6 if chair_z < -10.0 else 0.6))
   var chair_query := PhysicsRayQueryParameters3D.create(chair_start, Vector3(table_x,0.5,chair_z))
   var chair_hit := player.get_world_3d().direct_space_state.intersect_ray(chair_query)
   if not visual_found or chair_hit.is_empty() or not (chair_hit.collider as Node).is_in_group("new_furniture_collision"): all_chairs_aligned = false
 check(all_chairs_aligned, "all dining chair visuals align with their collision envelopes")
 var locke_route_query := PhysicsRayQueryParameters3D.create(Vector3(-38,4.4,-9), Vector3(-35.5,4.4,-9))
 locke_route_query.exclude = [player.get_rid(), npcs[3].get_rid()]
 check(player.get_world_3d().direct_space_state.intersect_ray(locke_route_query).is_empty(), "Locke's suite-local route clears solid furniture and walls")
 var window_query := PhysicsRayQueryParameters3D.create(Vector3(-30,2,15),Vector3(-30,2,17))
 var window_hit := player.get_world_3d().direct_space_state.intersect_ray(window_query)
 check(not window_hit.is_empty() and (window_hit.collider as Node).is_in_group("hotel_windows"), "visible window bays retain a physical exterior barrier")
 check(world.get("floor_finish") is ShaderMaterial, "Meridian stone and timber floors use the shared world-space finish")
 var screen_query := PhysicsRayQueryParameters3D.create(Vector3(-26,1.3,-6.4),Vector3(-26,1.3,-7.5))
 var screen_hit := player.get_world_3d().direct_space_state.intersect_ray(screen_query)
 check(not screen_hit.is_empty() and (screen_hit.collider as Node).is_in_group("new_furniture_collision"), "restaurant divider is physically solid away from its doorways")
 var approach := player.global_position
 player.global_position = Vector3(-36,0.05,-5.5)
 player.rotation.y = 0
 player.velocity = Vector3.ZERO
 await physics_frame
 Input.action_press("move_forward")
 await create_timer(1.4).timeout
 Input.action_release("move_forward")
 check(player.global_position.z < -7.5, "restaurant remains reachable through an open doorway")
 player.global_position = approach
 player.velocity = Vector3.ZERO
 var before_migration := player.global_position
 player.global_position = Vector3(-38,0.05,-8.45)
 check(world.call("_new_furniture_overlaps", player.global_position), "legacy position overlapping new chair is detected")
 var migrated: bool = world.call("_resolve_furniture_checkpoint")
 check(migrated and not bool(world.call("_new_furniture_overlaps", player.global_position)), "legacy checkpoint relocates out of new solid furniture")
 var old_save_path: String = world.get("save_path")
 var furniture_save := "user://furniture_migration_%d.json" % Time.get_ticks_usec()
 player.global_position = Vector3(-38,0.05,-8.45)
 var legacy_data := SessionSnapshot.capture(player, world.get("mission"))
 check(SaveStore.write(furniture_save, legacy_data), "write legacy furniture-position checkpoint")
 world.set("save_path", furniture_save)
 player.global_position = before_migration
 world.call("load_game")
 check(not bool(world.call("_new_furniture_overlaps", player.global_position)) and player.global_position.distance_to(Vector3(-38,0.05,-8.45)) > 0.1, "loading an old checkpoint moves player clear without discarding state")
 world.set("save_path", old_save_path)
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(furniture_save + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(furniture_save + suffix))
 player.global_position = before_migration
 player.velocity = Vector3.ZERO
 var spawned: Array[Interactable] = world.get("interactables")
 var spawned_ids: Array[String] = []
 for obj: Interactable in spawned:
  if obj.kind == "clue": spawned_ids.append(obj.identifier)
 var world_mission: Mission = world.get("mission")
 check(spawned_ids.size() == world_mission.available_records.size() and spawned_ids.size() == 3, "every configured record spawns exactly once")
 check(spawned_ids.has("ledger") and spawned_ids.has("memo") and spawned_ids.has("archive"), "all unique configured records spawn")
 var wing_npc: HotelNpc = npcs[4]
 var wing_start := wing_npc.global_position
 var upper_guest: HotelNpc = npcs[6]
 var upper_start := upper_guest.global_position
 await create_timer(1.5).timeout
 check(wing_npc.global_position.distance_to(wing_start) > 0.2 and wing_npc.global_position.y < 0.5, "wing staff follows a local ground-floor route")
 check(upper_guest.global_position.distance_to(upper_start) > 0.2 and absf(upper_guest.global_position.y - 3.6) < 0.2, "upstairs guest follows a separate local upper-floor route")
 var upper_query := PhysicsRayQueryParameters3D.create(Vector3(-17,4.4,-2), Vector3(-30,4.4,-2))
 upper_query.exclude = [player.get_rid(), upper_guest.get_rid()]
 check(player.get_world_3d().direct_space_state.intersect_ray(upper_query).is_empty(), "upper-floor route is clear of physical obstacles")
 var npc: HotelNpc = npcs[0]
 var npc_start := npc.global_position
 await create_timer(2.5).timeout
 check(npc.global_position.distance_to(npc_start) > 0.2, "scheduled NPC navigates toward its destination")
 var navmap: RID = player.get_world_3d().get_navigation_map()
 var records_on_navmesh := true
 for obj: Interactable in spawned:
  if obj.kind == "clue" and NavigationServer3D.map_get_closest_point(navmap, obj.global_position).distance_to(obj.global_position) > 0.5:
   records_on_navmesh = false
 check(records_on_navmesh, "all record markers are on the navigation mesh")
 await create_timer(2.0).timeout
 check(npc.schedule_index == 1, "NPC advances to the next scheduled destination")
 npc.facing = Vector3.FORWARD
 check(npc.can_see(npc.global_position + Vector3.FORWARD * 3.0), "NPC sees in field of view")
 check(not npc.can_see(npc.global_position + Vector3.BACK * 3.0), "NPC cannot see behind")
 check(not npc.can_see(npc.global_position + Vector3.FORWARD * 3.0, false), "occlusion prevents sight")
 npc.observe_trespass(Vector3(6, 0, 1))
 check(npc.state == "suspicious" and npc.memory.observations.size() == 1, "observation creates local memory and suspicion")
 npc.advance_simulation(0.1)
 check(npc.state == "investigating", "suspicion triggers investigation")
 npc.advance_simulation(11.0)
 check(npc.state == "returning", "investigation returns to routine")
 await create_timer(8.0).timeout
 check(npc.state not in ["investigating", "suspicious", "returning"], "NPC resumes its interrupted schedule")
 player.set_disguise("staff")
 check(player.role == "staff" and AccessRules.can_enter(player.role, "staff"), "disguise changes access")
 for existing: HotelNpc in npcs:
  existing.set_physics_process(false)
  existing.collision_layer = 0
 # Walk the actual continuous ramp in both directions; no teleport across floors.
 var upstairs_target: HotelNpc = world.get("primary_npc")
 check(upstairs_target.global_position.y > 3.4 and upstairs_target.global_position.x < -34, "Meridian target starts in upper private room")
 player.global_position = Vector3(-24,0.08,3)
 player.rotation.y = 0
 player.velocity = Vector3.ZERO
 await physics_frame
 Input.action_press("move_left")
 await create_timer(6.0).timeout
 Input.action_release("move_left")
 print("WING_DIAG: ascent=", player.global_position)
 check(player.global_position.x < -35.0 and player.global_position.y > 3.3, "player walks from ground level up the connected ramp")
 # Navigate around the stairwell and through the suite door to the real target.
 var before_suite := SessionSnapshot.capture(player, world_mission)
 Input.action_press("move_forward")
 await create_timer(2.0).timeout
 Input.action_release("move_forward")
 Input.action_press("move_right")
 await create_timer(2.7).timeout
 Input.action_release("move_right")
 Input.action_press("move_forward")
 await create_timer(2.7).timeout
 Input.action_release("move_forward")
 Input.action_press("move_left")
 await create_timer(2.0).timeout
 Input.action_release("move_left")
 print("WING_DIAG: suite=", player.global_position, " target=", upstairs_target.global_position)
 world.call("_interact_nearest")
 check(world_mission.target_complete and upstairs_target.objective_completed, "player reaches and interacts with upper-room target through physical route")
 SessionSnapshot.restore(before_suite, player, world_mission, spawned)
 # Return to stair landing for descent.
 player.global_position = Vector3(-38.5,3.65,3)
 player.velocity = Vector3.ZERO
 await physics_frame
 Input.action_press("move_right")
 await create_timer(6.0).timeout
 Input.action_release("move_right")
 print("WING_DIAG: descent=", player.global_position)
 check(player.global_position.x > -27.0 and player.global_position.y < 0.5, "player walks back down the connected ramp")
 check(HotelLayout.is_safe_player_position(Vector3(-38,3.65,-9)), "upper-floor checkpoint position accepted")
 # Exercise real player physics and input, away from walls and interactables.
 player.global_position = Vector3(-10, 0.1, 0)
 await physics_frame
 var start := player.global_position
 Input.action_press("move_forward")
 await create_timer(0.6).timeout
 Input.action_release("move_forward")
 var walk_distance: float = player.global_position.distance_to(start)
 check(walk_distance > 0.3, "input moves player through physics")
 Input.action_press("move_right")
 await create_timer(0.35).timeout
 Input.action_release("move_right")
 check(absf(player.body_mesh.rotation.y) > 0.25, "moving sideways smoothly turns the visible character")
 player.global_position = Vector3(-10, 0.1, 0)
 player.velocity = Vector3.ZERO
 await physics_frame
 start = player.global_position
 Input.action_press("sprint")
 Input.action_press("move_forward")
 await create_timer(0.6).timeout
 Input.action_release("move_forward")
 Input.action_release("sprint")
 var run_distance: float = player.global_position.distance_to(start)
 player.global_position = Vector3(-10, 0.1, 0)
 player.velocity = Vector3.ZERO
 await physics_frame
 start = player.global_position
 Input.action_press("crouch")
 Input.action_press("move_forward")
 await create_timer(0.6).timeout
 Input.action_release("move_forward")
 Input.action_release("crouch")
 var crouch_distance: float = player.global_position.distance_to(start)
 check(run_distance > walk_distance and walk_distance > crouch_distance, "run and crouch change movement speed")
 player.global_position = Vector3(1, 0.1, 0)
 player.velocity = Vector3.ZERO
 await physics_frame
 Input.action_press("move_right")
 await create_timer(0.8).timeout
 Input.action_release("move_right")
 check(player.global_position.x < 1.75, "player collides with partition")
 var map: RID = player.get_world_3d().get_navigation_map()
 var route: PackedVector3Array = NavigationServer3D.map_get_path(map, Vector3(0, 0, 0), Vector3(4, 0, 0), true)
 var detours: bool = false
 for point: Vector3 in route:
  if absf(point.z) > 2.0: detours = true
 check(route.size() >= 3 and detours, "navigation route detours through a partition opening")
 # Test actual throttled perception and physics occlusion, not only the FOV helper.
 for existing: HotelNpc in npcs:
  existing.set_physics_process(false)
  existing.collision_layer = 0
 var observer := HotelNpc.new()
 observer.profile = NpcProfile.new()
 observer.player = player
 observer.position = Vector3(1, 0.05, 0)
 world.add_child(observer)
 observer.facing = Vector3.RIGHT
 player.set_disguise("visitor")
 player.global_position = Vector3(3, 0.05, 0)
 await create_timer(0.9).timeout
 check(observer.memory.observations.is_empty(), "solid partition blocks NPC sight")
 observer.global_position = Vector3(1, 0.05, 3)
 player.global_position = Vector3(3, 0.05, 3)
 await create_timer(0.9).timeout
 check(not observer.memory.observations.is_empty() and observer.suspicion > 0.0, "NPC observes trespass through an opening")
 observer.set_physics_process(false)
 observer.collision_layer = 0
 # A waist-high solid barrier blocks the lower crouched sight ray, but not
 # the standing ray. This exercises real geometry instead of a stance bonus.
 var cover := StaticBody3D.new()
 var cover_shape := CollisionShape3D.new()
 var cover_box := BoxShape3D.new()
 cover_box.size = Vector3(0.2, 1.10, 2.0)
 cover_shape.shape = cover_box
 cover.add_child(cover_shape)
 world.add_child(cover)
 cover.global_position = Vector3(4.5, 0.55, 4.7)
 observer.global_position = Vector3(3.5, 0.05, 4.7)
 observer.facing = Vector3.RIGHT
 observer.memory.observations.clear()
 observer.suspicion = 0.0
 observer.state = "idle"
 player.global_position = Vector3(5.5, 0.05, 4.7)
 player.velocity = Vector3.ZERO
 await physics_frame
 observer.set_physics_process(true)
 await create_timer(0.9).timeout
 check(observer.suspicion > 0.0, "standing player is visible over low cover")
 observer.set_physics_process(false)
 observer.memory.observations.clear()
 observer.suspicion = 0.0
 observer.state = "idle"
 observer.global_position = Vector3(3.5, 0.05, 4.7)
 observer.velocity = Vector3.ZERO
 Input.action_press("crouch")
 await create_timer(0.4).timeout
 observer.set_physics_process(true)
 await create_timer(0.9).timeout
 print("STEALTH_DIAG: observer=", observer.global_position, " player=", player.global_position, " stance=", player.stance_height, " suspicion=", observer.suspicion)
 check(observer.suspicion == 0.0, "low solid cover blocks crouched sight ray")
 observer.set_physics_process(false)
 Input.action_release("crouch")
 cover.queue_free()
 await create_timer(0.4).timeout
 # Local visual discovery of an incapacitated person respects opaque cover.
 var down := HotelNpc.new()
 down.profile = NpcProfile.new()
 world.add_child(down)
 down.set_physics_process(false)
 down.global_position = Vector3(-4, 0.05, 0)
 down.stunned_time = 5.0
 observer.global_position = Vector3(-6, 0.05, 0)
 observer.facing = Vector3.RIGHT
 observer.state = "idle"
 observer.memory.observations.clear()
 var disturbance := DisturbanceSystem.new()
 disturbance.npcs = [observer, down]
 world.add_child(disturbance)
 disturbance.set_physics_process(false)
 var screen := StaticBody3D.new()
 var screen_shape := CollisionShape3D.new()
 var screen_box := BoxShape3D.new()
 screen_box.size = Vector3(0.2, 2.0, 2.0)
 screen_shape.shape = screen_box
 screen.add_child(screen_shape)
 world.add_child(screen)
 screen.global_position = Vector3(-5, 1, 0)
 await physics_frame
 disturbance._physics_process(1.0)
 check(observer.memory.observations.is_empty(), "unseen disturbance does not create global knowledge")
 screen.queue_free()
 await physics_frame
 disturbance._physics_process(1.0)
 check(observer.state == "suspicious" and observer.memory.observations.size() == 1 and observer.memory.observations[0].kind == "disturbance", "visible incapacitated NPC triggers local investigation")
 disturbance.queue_free()
 down.queue_free()
 player.set_disguise("staff")
 # Interaction selection must not reach through a wall, even within range.
 var objects: Array[Interactable] = world.get("interactables")
 var blocked_object := Interactable.new()
 blocked_object.position = Vector3(2.8, 0, 0)
 world.add_child(blocked_object)
 objects.append(blocked_object)
 player.global_position = Vector3(1.2, 0.05, 0)
 await physics_frame
 check(world.call("_nearest") != blocked_object, "interaction cannot reach through a wall")
 blocked_object.position = Vector3(2.8, 0, 3)
 player.global_position = Vector3(1.2, 0.05, 3)
 await physics_frame
 check(world.call("_nearest") == blocked_object, "interaction can reach through an opening")
 objects.erase(blocked_object)
 blocked_object.queue_free()
 # Exercise the actual interaction signal path and objective progression.
 player.global_position = objects[0].global_position + Vector3(0, 0.1, 0.5)
 player.inventory.capacity = 0
 world.call("_interact_nearest")
 check(not objects[0].used and world_mission.clues.is_empty(), "full inventory does not consume or count record")
 player.inventory.capacity = 6
 var interaction_event := InputEventAction.new()
 interaction_event.action = "interact"
 interaction_event.pressed = true
 player._unhandled_input(interaction_event)
 var active_mission: Mission = world.get("mission")
 check(active_mission.clues.has("ledger") and player.inventory.has_item("ledger"), "world interaction records clue and item")
 player.global_position = objects[1].global_position + Vector3(0, 0.1, 0.5)
 world.call("_interact_nearest")
 player.global_position = objects[4].global_position + Vector3(0, 0.1, 0.5)
 world.call("_interact_nearest")
 check(not active_mission.extracted, "Meridian exit requires target as well as records")
 var witness: Interactable = objects[5]
 var witness_npc := witness.get_parent() as HotelNpc
 witness_npc.stunned_time = 1.0
 world.call("_on_interaction", witness)
 check(not active_mission.action_complete, "incapacitated witness cannot be questioned")
 witness_npc.stunned_time = 0.0
 player.global_position = witness.global_position + Vector3(0, 0.1, 0.7)
 await physics_frame
 var question := InputEventAction.new()
 question.action = "interact"
 question.pressed = true
 Input.parse_input_event(question)
 await process_frame
 await physics_frame
 await process_frame
 check(active_mission.action_complete, "physical Ivo target can be questioned through input")
 question.pressed = false
 Input.parse_input_event(question)
 player.global_position = objects[4].global_position + Vector3(0, 0.1, 0.5)
 world.call("_interact_nearest")
 check(not active_mission.extracted, "witness and records do not replace primary target")
 var primary: Interactable = objects[6]
 check(primary.get_parent() is HotelNpc and (primary.get_parent() as HotelNpc).profile.identity == "Adrian Locke", "primary target is a distinct scheduled character")
 player.global_position = primary.global_position + Vector3(0, 0.1, 0.7)
 await physics_frame
 world.call("_interact_nearest")
 check(active_mission.target_complete and (primary.get_parent() as HotelNpc).objective_completed, "confronting primary target updates objective and ends routine")
 var completed_npc := primary.get_parent() as HotelNpc
 completed_npc.advance_simulation(60.0)
 completed_npc.observe_trespass(player.global_position)
 check(completed_npc.state == "objective_completed" and not completed_npc.incapacitate(5.0), "completed target cannot resume AI or become temporarily incapacitated")
 player.global_position = objects[4].global_position + Vector3(0, 0.1, 0.5)
 world.call("_interact_nearest")
 check(active_mission.extracted, "world interactions complete mission")
 world.call("_interact_nearest")
 check(str(world.get("message")).contains("already complete"), "repeat extraction does not show a false requirement")
 # Exercise the actual world F5/F9 handlers with an isolated, unique save file.
 var world_save := "user://assassin_test_%d.json" % Time.get_ticks_usec()
 world.set("save_path", world_save)
 var save_event := InputEventAction.new()
 save_event.action = "save_game"
 save_event.pressed = true
 world.call("_unhandled_input", save_event)
 check(FileAccess.file_exists(world_save), "save action writes a mission save")
 var snapshot := SessionSnapshot.capture(player, active_mission)
 active_mission.clues.clear()
 active_mission.extracted = false
 player.set_disguise("visitor")
 var load_event := InputEventAction.new()
 load_event.action = "load_game"
 load_event.pressed = true
 world.call("_unhandled_input", load_event)
 check(active_mission.extracted and player.role == "staff", "load action restores saved gameplay state")
 SessionSnapshot.restore(snapshot, player, active_mission, objects)
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(world_save + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(world_save + suffix))
 check(active_mission.extracted and active_mission.clues.size() == 2 and player.role == "staff" and active_mission.target_complete and primary.used, "snapshot restores mission, primary target and disguise")
 check(objects[0].used and not objects[0].visible and player.inventory.has_item("ledger"), "snapshot restores world markers and inventory")
 SessionSnapshot.restore({"clues": ["ledger", "ledger", "invalid"], "role": 42, "extracted": true, "position": ["invalid", 0, 0]}, player, active_mission, objects)
 check(active_mission.clues.size() == 1 and not active_mission.extracted and player.role == "visitor", "snapshot safely handles malformed data")
 var safe_position := player.global_position
 SessionSnapshot.restore({"position": [2, 0, 0]}, player, active_mission, objects)
 check(player.global_position == safe_position, "snapshot refuses position inside a wall")
 player.inventory.capacity = 1
 SessionSnapshot.restore({"clues": ["ledger", "memo"], "extracted": true}, player, active_mission, objects)
 check(active_mission.clues.size() == 1 and player.inventory.items.size() == 1 and not active_mission.extracted, "snapshot cannot exceed inventory capacity")
 player.inventory.capacity = 6
 player.global_position = objects[1].global_position + Vector3(0, 0.1, 0.5)
 world.call("_interact_nearest")
 player.global_position = objects[2].global_position + Vector3(0, 0.1, 0.5)
 world.call("_interact_nearest")
 world.call("_process", 0.0)
 var hud: Label = world.get("hud")
 check(active_mission.clues.size() == 3 and hud.text.contains("3 / 3") and hud.text.contains("REQUIRED 2"), "HUD reflects collected, available and required records")
 var before_duplicate: int = active_mission.clues.size()
 world.call("_on_interaction", objects[2])
 check(active_mission.clues.size() == before_duplicate, "repeated collection does not duplicate progress")
 SessionSnapshot.restore({"clues": ["ledger", "memo"], "extracted": true, "action_complete": false}, player, active_mission, objects)
 check(active_mission.action_complete and active_mission.extracted, "completed legacy Meridian checkpoint migrates witness objective")
 SessionSnapshot.restore({"clues": ["ledger", "memo"], "extracted": true, "action_id": "disable_assessment_unit", "action_complete": true, "target_id": "adrian_locke", "target_complete": true}, player, active_mission, objects)
 check(not active_mission.action_complete and not active_mission.extracted, "a different mission's action ID cannot complete Meridian")
 world.queue_free()
 await process_frame
 var campaign := CampaignProgress.new()
 var campaign_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://resources/campaign.json"))
 check(campaign.configure(campaign_data), "campaign data loads")
 check(campaign.is_unlocked("initiation") and not campaign.is_unlocked("meridian") and not campaign.is_unlocked("future"), "campaign starts in chronological order")
 check(not campaign.item_unlocked("quiet_line") and not campaign.select_item("quiet_line"), "locked equipment cannot be selected")
 check(campaign.mark_complete("initiation") and not campaign.is_unlocked("meridian") and campaign.item_unlocked("quiet_line"), "completion unlocks quiet line without presenting Meridian ahead of the main story")
 check(campaign.next_mission() == "tung_chung" and not campaign.is_unlocked("meridian"), "Tung Chung follows Initiation while optional Meridian remains out of the required sequence")
 check(campaign.select_item("quiet_line") and campaign.item_allowed("quiet_line", "meridian") and not campaign.item_allowed("quiet_line", "initiation"), "equipment restrictions enforced by campaign data")
 var campaign_copy := CampaignProgress.new()
 campaign_copy.configure(campaign_data)
 campaign_copy.restore(campaign.snapshot())
 check(campaign_copy.completed.has("initiation") and campaign_copy.selected == "quiet_line" and campaign_copy.is_unlocked("initiation"), "campaign progress and replay survive restore")
 campaign_copy.restore({"completed": ["initiation", "meridian"], "last_mission": "meridian"})
 check(campaign_copy.completed.has("initiation") and not campaign_copy.completed.has("meridian") and campaign_copy.last_mission.is_empty(), "legacy saves keep safe training progress but cannot skip newly mandatory operations")
 campaign_copy.restore({"completed": ["meridian"], "selected": "quiet_line"})
 check(campaign_copy.completed.is_empty() and campaign_copy.selected == "training_sidearm", "out-of-order save cannot bypass unlocks")
 var gadget_world: Node = scene.instantiate()
 root.add_child(gadget_world)
 await process_frame
 await physics_frame
 var gadget_player: HotelPlayer = gadget_world.get("player")
 var gadget_npcs: Array[HotelNpc] = gadget_world.get("npcs")
 gadget_player.equipment.configure(campaign, "meridian")
 check(gadget_player.equipment.available.has("quiet_line") and gadget_player.equipment.selected == "quiet_line", "unlocked selected gadget is provisioned in Meridian")
 var guard: HotelNpc = gadget_npcs[0]
 for person: HotelNpc in gadget_npcs:
  person.set_physics_process(false)
  person.collision_layer = 0
 guard.global_position = Vector3(-9, 0.05, 1)
 gadget_player.global_position = Vector3(-9, 0.05, 2)
 await physics_frame
 var select_event := InputEventAction.new()
 select_event.action = "equip_secondary"
 select_event.pressed = true
 Input.parse_input_event(select_event)
 var gadget_event := InputEventAction.new()
 gadget_event.action = "use_equipment"
 gadget_event.pressed = true
 Input.parse_input_event(gadget_event)
 await process_frame
 await physics_frame
 await process_frame
 print("EQUIP_DIAG: gadget selected=", gadget_player.equipment.selected, " stun=", guard.stunned_time, " message=", gadget_world.get("message"))
 check(guard.stunned_time > 0 and gadget_player.equipment.selected == "quiet_line", "gadget input temporarily disables a nearby NPC")
 check(gadget_player.body_mesh.quiet_tool.visible and gadget_player.body_mesh.quiet_tool_action > 0.0, "selected gadget has a hand-held visual and use pose")
 var locke: HotelNpc = gadget_world.get("primary_npc")
 locke.global_position = gadget_player.global_position + Vector3(0, 0, -0.6)
 gadget_world.call("_use_equipment")
 var meridian_mission: Mission = gadget_world.get("mission")
 check(meridian_mission.target_temporarily_incapacitated and not meridian_mission.target_complete and not meridian_mission.can_extract(), "Quiet Line incapacitates Locke temporarily without completing the mandatory target")
 var temporary_snapshot := SessionSnapshot.capture(gadget_player, meridian_mission, locke)
 locke._physics_process(13.0)
 gadget_world.call("_process", 0.0)
 check(not meridian_mission.target_temporarily_incapacitated and not meridian_mission.target_complete, "target recovery clears temporary status without awarding permanent completion")
 var temp_target_objects: Array[Interactable] = gadget_world.get("interactables")
 SessionSnapshot.restore(temporary_snapshot, gadget_player, meridian_mission, temp_target_objects)
 check(meridian_mission.target_temporarily_incapacitated and locke.stunned_time > 0.0 and not meridian_mission.target_complete, "checkpoint preserves recoverable target incapacitation without promoting it to completion")
 locke._physics_process(13.0)
 gadget_world.call("_process", 0.0)
 check(not meridian_mission.target_temporarily_incapacitated and not locke.objective_completed, "checkpoint-restored target still recovers normally")
 gadget_world.call("_process", 0.0)
 check(gadget_world.get("hud").text.contains("ADRIAN LOCKE") and gadget_world.get("equipment_hud").text.contains("QUIET LINE"), "Meridian HUD displays target and equipped gadget")
 check(gadget_world.get("equipment_icon").item == "quiet_line", "equipment icon reflects the actual selected item")
 locke.global_position = Vector3(-8.5, 0.05, 0)
 gadget_player.global_position = Vector3(-9, 0.05, 2)
 await physics_frame
 gadget_player.camera.look_at(locke.global_position + Vector3.UP, Vector3.UP)
 meridian_mission.target_discovered = false
 var instinct_event := InputEventKey.new()
 instinct_event.physical_keycode = KEY_CTRL
 instinct_event.location = KEY_LOCATION_LEFT
 instinct_event.pressed = true
 Input.parse_input_event(instinct_event)
 await process_frame
 await physics_frame
 await process_frame
 check(meridian_mission.target_discovered and locke.person.torso.material_overlay == gadget_world.get("instinct_red"), "seen Meridian primary target highlights red")
 var hotel_objects: Array[Interactable] = gadget_world.get("interactables")
 var hotel_near: Interactable = hotel_objects[0]
 var hotel_far: Interactable = hotel_objects[1]
 var hotel_far_original := hotel_far.position
 hotel_far.position = hotel_near.position + Vector3(0, 0, -3.5)
 gadget_player.global_position = hotel_near.global_position + Vector3(0, 0.05, 1)
 await physics_frame
 gadget_player.camera.look_at(hotel_near.global_position + Vector3.UP * 0.4, Vector3.UP)
 await process_frame
 await physics_frame
 await process_frame
 check((hotel_near.get_child(0) as MeshInstance3D).material_overlay != null and (hotel_far.get_child(0) as MeshInstance3D).material_overlay == null and bool(gadget_world.call("_in_player_view", hotel_far.global_position + Vector3.UP * 0.4)), "Meridian Instinct uses the same nearby-only item range")
 hotel_far.position = hotel_far_original
 instinct_event.pressed = false
 Input.parse_input_event(instinct_event)
 await process_frame
 await physics_frame
 await process_frame
 check(locke.person.torso.material_overlay == null, "Meridian target highlight clears on release")
 var gadget_snapshot := SessionSnapshot.capture(gadget_player, gadget_world.get("mission"))
 var equipment_save := "user://assassin_equipment_test_%d.json" % Time.get_ticks_usec()
 check(SaveStore.write(equipment_save, gadget_snapshot), "equipment checkpoint writes to disk")
 gadget_player.equipment.configure(campaign_copy, "meridian")
 SessionSnapshot.restore(SaveStore.read(equipment_save), gadget_player, gadget_world.get("mission"), gadget_world.get("interactables"), Callable(gadget_world, "safe_position"), campaign)
 check(gadget_player.equipment.available.has("quiet_line") and gadget_player.equipment.selected == "quiet_line", "checkpoint restores unlocked gadget selection")
 gadget_player.equipment.configure(campaign_copy, "meridian")
 SessionSnapshot.restore(gadget_snapshot, gadget_player, gadget_world.get("mission"), gadget_world.get("interactables"), Callable(gadget_world, "safe_position"), campaign_copy)
 check(not gadget_player.equipment.available.has("quiet_line"), "checkpoint cannot grant a locked gadget")
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(equipment_save + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(equipment_save + suffix))
 guard._physics_process(13.0)
 check(guard.stunned_time == 0.0 and guard.state == "returning" and not guard.objective_completed, "ordinary temporary incapacitation recovers without completing an objective")
 # Fire through the actual center-ray path at the physical Meridian target.
 for person: HotelNpc in gadget_npcs: person.collision_layer = 0
 locke.collision_layer = 1
 locke.global_position = Vector3(-4, 0.05, 0)
 gadget_player.global_position = Vector3(-4, 0.05, -3)
 gadget_player.rotation.y = PI
 gadget_player.equipment.configure(campaign, "meridian")
 gadget_player.equipment.selected = "training_sidearm"
 gadget_player.aiming = true
 for i: int in range(5): await physics_frame
 gadget_player.camera.look_at(locke.global_position + Vector3.UP, Vector3.UP)
 gadget_world.call("_fire")
 print("EQUIP_DIAG: locke-shot message=", gadget_world.get("message"), " camera=", gadget_player.camera.global_position, " target=", locke.global_position, " charge=", gadget_player.equipment.charges)
 check(meridian_mission.target_complete and meridian_mission.target_incapacitated and locke.objective_completed and locke.completed_incapacitated, "center-ray shot completes physical target permanently")
 var terminal_save := SessionSnapshot.capture(gadget_player, meridian_mission)
 locke._physics_process(100.0)
 locke.observe_trespass(gadget_player.global_position)
 check(locke.state == "objective_completed" and is_equal_approx(locke.person.rotation.z, 1.0), "completed shot target stays down beyond recovery and ignores observations")
 var completion_events := [0]
 meridian_mission.changed.connect(func() -> void: completion_events[0] += 1)
 check(not meridian_mission.mark_target("adrian_locke", true) and completion_events[0] == 0, "repeated target completion emits no duplicate event")
 SessionSnapshot.restore({"target_id": "adrian_locke", "target_complete": false}, gadget_player, meridian_mission, hotel_objects)
 check(not locke.objective_completed and not meridian_mission.target_complete, "loading earlier checkpoint restores active target")
 SessionSnapshot.restore(terminal_save, gadget_player, meridian_mission, hotel_objects)
 locke._physics_process(100.0)
 check(locke.objective_completed and locke.completed_incapacitated and locke.state == "objective_completed", "checkpoint restores permanent incapacitated pose and objective")
 gadget_world.queue_free()
 await process_frame
 var station: Node3D = load("res://scenes/tung_chung_preview.tscn").instantiate()
 root.add_child(station)
 await process_frame
 await physics_frame
 var station_people: Array[HotelNpc] = station.get("npcs")
 var station_player: HotelPlayer = station.get("player")
 var suspect: HotelNpc = station.get("robber")
 check(station_people.size() == 16 and suspect != station.get("operative"), "station preview creates two distinct physical characters and fourteen passengers")
 # NavigationServer publishes region changes asynchronously on physics
 # frames; wait for the prior world's region to disappear and this one to sync.
 for frame: int in range(5): await physics_frame
 var station_map: RID = station_player.get_world_3d().get_navigation_map()
 var island_path: PackedVector3Array = NavigationServer3D.map_get_path(station_map, Vector3(-5,0,0), Vector3(3,0,0), true)
 var avoids_island := false
 for point: Vector3 in island_path:
  if absf(point.z) > 1.3: avoids_island = true
 if not avoids_island: print("STATION_NAV_DIAG: ", island_path)
 check(island_path.size() >= 3 and avoids_island, "station navigation routes around the solid information island")
 var station_start := station_people[0].global_position
 await create_timer(1.5).timeout
 check(station_people[0].global_position.distance_to(station_start) > 0.1, "station passenger follows a navigation schedule")
 station_player.global_position = suspect.global_position + Vector3(0, 0, 1)
 station.call("_interact")
 check(str(station.get("message")).contains("suspect"), "station preview observes physical suspect nearby")
 station.queue_free()
 await process_frame
 var initiation_scene: PackedScene = load("res://scenes/initiation.tscn")
 var initiation: Node = initiation_scene.instantiate()
 root.add_child(initiation)
 await process_frame
 await physics_frame
 var init_mission: Mission = initiation.get("mission")
 var init_player: HotelPlayer = initiation.get("player")
 var init_objects: Array[Interactable] = initiation.get("interactables")
 var init_npcs: Array[HotelNpc] = initiation.get("npcs")
 check(init_mission.configured and init_npcs.size() == 2, "Initiation spawns configured mission and exactly two guards")
 initiation.call("_process", 0.0)
 check(initiation.get("hud").text.contains("ASSESSMENT UNIT") and initiation.get("equipment_hud").text.contains("5 / 5"), "Initiation HUD shows target and real starting charges")
 check(init_player.body_mesh is StylizedPerson and init_npcs[0].person is StylizedPerson, "player and guard spawn articulated visual characters")
 check(init_player.body_mesh.cc0_model != null and init_npcs[0].person.cc0_model != null and init_player.body_mesh.cc0_skeleton.get_bone_count() >= 150 and init_player.body_mesh.cc0_model.visible and init_player.body_mesh.cc0_model_name != init_npcs[0].person.cc0_model_name, "player and multiple NPC roles render distinct imported skinned MakeHuman characters")
 check(init_player.body_mesh.upper_body.visible == false and not init_player.body_mesh.left_leg.visible and init_player.body_mesh.cc0_bones.has("upperleg01.L"), "imported character replaces placeholder geometry and exposes animation bones")
 check(init_player.body_mesh.left_elbow != null and init_player.body_mesh.right_elbow != null and init_player.body_mesh.weapon.get_parent() == init_player.body_mesh.right_hand_attachment, "sidearm attaches to the imported animated hand")
 check(init_player.body_mesh.left_knee.get_child(0) is MeshInstance3D and (init_player.body_mesh.left_knee.get_child(0) as MeshInstance3D).mesh is CylinderMesh, "character legs use tapered articulated geometry")
 check(ProceduralSound.ambience("hotel").loop_mode == AudioStreamWAV.LOOP_FORWARD and ProceduralSound.ambience("hotel") == ProceduralSound.ambience("hotel"), "original ambient bed loops and is cached")
 var start_guard := init_npcs[0].global_position
 init_player.global_position = Vector3(-12, 0.05, 0)
 Input.action_press("crouch")
 await create_timer(0.4).timeout
 check(init_player.crouching and init_player.stance_height < 1.3 and init_player.pivot.position.y < 1.2, "crouch smoothly lowers collision and camera")
 check(init_player.body_mesh.scale == Vector3.ONE and init_player.body_mesh.upper_body.position.y < -0.35 and init_player.body_mesh.left_knee.rotation.x < -0.8, "crouch bends knees and lowers torso without shrinking character")
 var ceiling := StaticBody3D.new()
 var ceiling_collision := CollisionShape3D.new()
 var ceiling_box := BoxShape3D.new()
 ceiling_box.size = Vector3(2, 0.2, 2)
 ceiling_collision.shape = ceiling_box
 ceiling.add_child(ceiling_collision)
 initiation.add_child(ceiling)
 ceiling.global_position = init_player.global_position + Vector3.UP * 1.4
 await physics_frame
 Input.action_release("crouch")
 await create_timer(0.4).timeout
 check(init_player.crouching and init_player.stance_height < 1.3, "ceiling prevents standing into solid geometry")
 ceiling.queue_free()
 await create_timer(0.4).timeout
 check(not init_player.crouching and init_player.stance_height > 1.75, "player stands after crouch when space is clear")
 check(init_player.body_mesh.upper_body.position.y > -0.2 and absf(init_player.body_mesh.left_knee.rotation.x) < 0.5, "standing smoothly restores posture")
 check(init_npcs[0].global_position.distance_to(start_guard) > 0.2, "Initiation guard follows its route")
 for init_guard: HotelNpc in init_npcs: init_guard.collision_layer = 0
 var nearby: Interactable = init_objects[0]
 var far_item: Interactable = init_objects[1]
 var far_original := far_item.position
 far_item.position = nearby.position + Vector3(0, 0, -3.5)
 init_player.global_position = nearby.global_position + Vector3(0, 0.05, 1.0)
 await physics_frame
 init_player.camera.look_at(nearby.global_position + Vector3.UP * 0.4, Vector3.UP)
 var ctrl := InputEventKey.new()
 ctrl.physical_keycode = KEY_CTRL
 ctrl.location = KEY_LOCATION_LEFT
 ctrl.pressed = true
 Input.parse_input_event(ctrl)
 await process_frame
 await physics_frame
 await process_frame
 var nearby_visual := nearby.get_child(0) as MeshInstance3D
 var far_visual := far_item.get_child(0) as MeshInstance3D
 check(init_player.instinct_active and initiation.get("instinct_label").visible, "left control enables Instinct and its HUD indicator")
 check(nearby_visual.material_overlay != null and far_visual.material_overlay == null and bool(initiation.call("_in_player_view", far_item.global_position + Vector3.UP * 0.4)), "Instinct highlights nearby but not distant visible intel")
 far_item.position = far_original
 check(init_npcs[0].person.torso.material_overlay == null, "ordinary NPCs are not highlighted")
 var robot_target: Interactable = initiation.get("robot")
 init_mission.target_discovered = false
 var away := init_player.camera.global_position - (robot_target.global_position - init_player.camera.global_position)
 init_player.camera.look_at(away, Vector3.UP)
 await process_frame
 await physics_frame
 await process_frame
 check(not init_mission.target_discovered and (robot_target.get_child(0) as MeshInstance3D).material_overlay == null, "Instinct does not reveal an unseen primary target")
 init_player.global_position = robot_target.global_position + Vector3(0, 0.05, 2)
 await physics_frame
 init_player.camera.look_at(robot_target.global_position + Vector3.UP, Vector3.UP)
 init_mission.target_discovered = false
 await process_frame
 await physics_frame
 await process_frame
 check(init_mission.target_discovered and (robot_target.get_child(0) as MeshInstance3D).material_overlay == initiation.get("instinct_red"), "seen assessment unit highlights red in Instinct")
 ctrl.pressed = false
 Input.parse_input_event(ctrl)
 await process_frame
 await physics_frame
 await process_frame
 check(not init_player.instinct_active and nearby_visual.material_overlay == null, "releasing left control immediately clears Instinct")
 var right_ctrl := InputEventKey.new()
 right_ctrl.physical_keycode = KEY_CTRL
 right_ctrl.location = KEY_LOCATION_RIGHT
 right_ctrl.pressed = true
 Input.parse_input_event(right_ctrl)
 await process_frame
 await physics_frame
 await process_frame
 check(not init_player.instinct_active, "right control does not activate left-control Instinct")
 right_ctrl.pressed = false
 Input.parse_input_event(right_ctrl.duplicate())
 for obj: Interactable in init_objects:
  if obj.kind == "clue": initiation.call("_on_interaction", obj)
 check(init_mission.clues.size() == 3 and not init_mission.can_extract(), "three records alone cannot complete assessment")
 var before_robot := SessionSnapshot.capture(init_player, init_mission)
 var assessment: Interactable = null
 for obj: Interactable in init_objects:
  if obj.kind == "robot": assessment = obj
 for init_guard: HotelNpc in init_npcs:
  init_guard.set_physics_process(false)
  init_guard.collision_layer = 0
 init_player.global_position = assessment.global_position + Vector3(0, 0.05, 1)
 await physics_frame
 await physics_frame
 check(initiation.get("robot_alert") == true, "assessment unit reacts to nearby visible player")
 initiation.set_physics_process(false)
 var aim_event := InputEventMouseButton.new()
 aim_event.button_index = MOUSE_BUTTON_RIGHT
 aim_event.pressed = true
 print("EQUIP_DIAG: before mouse aim captured=", Input.mouse_mode, " mapped=", aim_event.is_action_pressed("aim"), " backend=", DisplayServer.get_name())
 Input.parse_input_event(aim_event)
 await create_timer(0.5).timeout
 print("EQUIP_DIAG: after mouse aim captured=", Input.mouse_mode, " aiming=", init_player.aiming, " arm=", init_player.arm.spring_length)
 initiation.call("_process", 0.0)
 check(init_player.aiming and initiation.get("crosshair").visible and init_player.arm.spring_length < 3.0, "right mouse aims, moves camera and displays crosshair")
 init_player.camera.look_at(assessment.global_position + Vector3.UP * 0.65, Vector3.UP)
 await physics_frame
 var fire_event := InputEventMouseButton.new()
 fire_event.button_index = MOUSE_BUTTON_LEFT
 fire_event.pressed = true
 Input.parse_input_event(fire_event)
 await process_frame
 await physics_frame
 await process_frame
 print("EQUIP_DIAG: robot=", init_mission.action_complete, " charges=", init_player.equipment.charges, " message=", initiation.get("message"))
 check(init_mission.action_complete and init_player.equipment.charges == 4, "center-camera shot hits assessment unit and spends one charge")
 for i: int in range(5):
  fire_event.pressed = false
  Input.parse_input_event(fire_event.duplicate())
  fire_event.pressed = true
  Input.parse_input_event(fire_event.duplicate())
  await process_frame
  await physics_frame
 initiation.call("_process", 0.0)
 check(init_player.equipment.charges == 0 and initiation.get("equipment_hud").text.contains("0 / 5"), "five-charge limit and HUD update follow firing input")
 aim_event.pressed = false
 Input.parse_input_event(aim_event)
 await process_frame
 await physics_frame
 initiation.call("_process", 0.0)
 check(not init_player.aiming and not initiation.get("crosshair").visible, "releasing right mouse exits aim and hides crosshair")
 check(init_mission.action_complete and init_mission.can_extract(), "assessment unit and three unique records unlock exit")
 var after_robot := SessionSnapshot.capture(init_player, init_mission)
 SessionSnapshot.restore(before_robot, init_player, init_mission, init_objects, Callable(initiation, "safe_position"), campaign)
 check(init_player.equipment.charges == 5, "checkpoint restores training charges")
 check(not init_mission.action_complete and not init_mission.can_extract(), "snapshot restores active unit")
 SessionSnapshot.restore(after_robot, init_player, init_mission, init_objects, Callable(initiation, "safe_position"), campaign)
 check(init_player.equipment.charges == 0, "checkpoint preserves spent charges")
 check(init_mission.action_complete and init_mission.clues.size() == 3 and init_mission.can_extract(), "snapshot restores disabled unit and all records")
 SessionSnapshot.restore({"action_id": "interview_ivo", "action_complete": true}, init_player, init_mission, init_objects, Callable(initiation, "safe_position"))
 check(not init_mission.action_complete, "a different mission's action ID cannot disable the assessment unit")
 SessionSnapshot.restore({"action_complete": true}, init_player, init_mission, init_objects, Callable(initiation, "safe_position"))
 check(init_mission.action_complete, "older Initiation snapshots without action IDs retain their completed unit")
 SessionSnapshot.restore(after_robot, init_player, init_mission, init_objects, Callable(initiation, "safe_position"), campaign)
 for obj: Interactable in init_objects:
  if obj.kind == "extract": initiation.call("_on_interaction", obj)
 check(init_mission.extracted, "Initiation exit completes only after objectives")
 initiation.queue_free()
 await process_frame
 # Exercise actual campaign scene changes against an isolated campaign save.
 var service := root.get_node("Campaign")
 var saved_progress: Dictionary = service.progress.snapshot()
 var saved_path: String = service.campaign_path
 var isolated_path := "user://assassin_campaign_test_%d.json" % Time.get_ticks_usec()
 service.campaign_path = isolated_path
 service.progress.restore({})
 check(service.begin("initiation"), "campaign begins an unlocked mission")
 await process_frame
 await process_frame
 var deployed: Node = current_scene
 check(deployed != null and deployed.scene_file_path == "res://scenes/initiation.tscn", "campaign changes to Initiation scene")
 if deployed != null and deployed.scene_file_path == "res://scenes/initiation.tscn":
  check(deployed.get("intro_active") and not (deployed.get("player") as HotelPlayer).is_physics_processing(), "Initiation starts with a skippable entry cinematic")
  var entry_skip := InputEventAction.new()
  entry_skip.action = "release_mouse"
  entry_skip.pressed = true
  deployed.get("entry_intro").call("_input", entry_skip)
  check(not deployed.get("intro_active") and (deployed.get("player") as HotelPlayer).is_physics_processing(), "skipping entry cinematic restores the player")
  var pause_menu: Node = null
  for child: Node in deployed.get_children():
   if child.get_script() and child.get_script().resource_path == "res://scripts/ui/pause_menu.gd": pause_menu = child
  check(pause_menu != null, "campaign mission creates pause menu")
  if pause_menu:
   var escape_event := InputEventAction.new()
   escape_event.action = "release_mouse"
   escape_event.pressed = true
   pause_menu.call("_input", escape_event)
   check(paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "pause stops simulation and releases mouse")
   pause_menu.call("_resume")
   check(not paused, "resume restarts simulation")
  else:
   check(false, "pause stops simulation and releases mouse")
   check(false, "resume restarts simulation")
  var deployed_objects: Array[Interactable] = deployed.get("interactables")
  for obj: Interactable in deployed_objects:
   if obj.kind == "clue" or obj.kind == "robot": deployed.call("_on_interaction", obj)
  for obj: Interactable in deployed_objects:
   if obj.kind == "extract": deployed.call("_on_interaction", obj)
  await process_frame
  await process_frame
  check(current_scene != null and current_scene.scene_file_path == "res://scenes/ruby_meeting.tscn" and service.progress.is_unlocked("tung_chung") and not service.progress.is_unlocked("meridian"), "Initiation completion opens Ruby's handoff and unlocks Tung Chung, not optional Meridian")
  if current_scene != null and current_scene.scene_file_path == "res://scenes/ruby_meeting.tscn":
   current_scene.call("_apply_timeline", 6.0, 0.1)
   check(current_scene.get("actor").position.z < 0.0 and current_scene.get("left_door").position.x < -2.0, "cinematic timeline opens doors and walks outside")
   current_scene.call("_process", 1.2)
   check(current_scene.get("door_played") and current_scene.get("effects").stream != null, "cinematic starts synthesized door sound")
   var skip_event := InputEventAction.new()
   skip_event.action = "release_mouse"
   skip_event.pressed = true
   Input.parse_input_event(skip_event)
   await process_frame
   await physics_frame
   await process_frame
   check(service.progress.is_unlocked("tung_chung") and not service.progress.is_unlocked("meridian"), "skipping Ruby scene preserves the required Tung Chung unlock")
  else:
   check(false, "cinematic timeline opens doors and walks outside")
   check(false, "cinematic starts synthesized door sound")
   check(false, "skipping Ruby scene preserves the required Tung Chung unlock")
  if current_scene != null and current_scene.scene_file_path == "res://scenes/ending.tscn":
   current_scene.call("_continue")
   await process_frame
   await process_frame
   check(current_scene != null and current_scene.scene_file_path == "res://scenes/main_menu.tscn", "debrief can be skipped to main menu")
  else: check(false, "debrief can be skipped to main menu")
 else:
  check(false, "campaign mission creates pause menu")
  check(false, "pause stops simulation and releases mouse")
  check(false, "resume restarts simulation")
  check(false, "Initiation completion opens Ruby's handoff and unlocks Tung Chung, not optional Meridian")
  check(false, "cinematic timeline opens doors and walks outside")
  check(false, "cinematic starts synthesized door sound")
  check(false, "skipping Ruby scene preserves the required Tung Chung unlock")
  check(false, "debrief can be skipped to main menu")
 if current_scene != null and current_scene.scene_file_path == "res://scenes/main_menu.tscn":
  check(service.begin("initiation"), "completed Initiation can be replayed")
  await process_frame
  await process_frame
  check(current_scene != null and current_scene.scene_file_path == "res://scenes/initiation.tscn" and service.progress.is_unlocked("tung_chung") and not service.progress.is_unlocked("meridian"), "Initiation replay preserves Tung Chung access without unlocking optional Meridian")
 else:
  check(false, "completed Initiation can be replayed")
  check(false, "Initiation replay preserves Tung Chung access without unlocking optional Meridian")
 if current_scene != null:
  current_scene.queue_free()
  current_scene = null
 # Verify settings controls and Back are actually reachable at the design
 # resolution, rather than merely checking that a panel was instantiated.
 var settings_menu: Control = load("res://scenes/main_menu.tscn").instantiate()
 root.add_child(settings_menu)
 await process_frame
 settings_menu.call("_settings")
 await process_frame
 await process_frame
 var settings_panel: Control = settings_menu.get("panel").get_child(0)
 var sfx_slider := settings_panel.find_child("sfx_volume", true, false) as HSlider
 check(sfx_slider != null, "settings exposes an SFX volume control")
 if sfx_slider:
  var saved_sfx: float = settings_service.settings["sfx_volume"]
  sfx_slider.value = 0.35
  check(is_equal_approx(settings_service.settings["sfx_volume"], 0.35) and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))), 0.35), "settings slider applies SFX volume live")
  sfx_slider.value = saved_sfx
 var settings_fit := true
 for child: Node in settings_panel.get_children():
  if child is Control and not root.get_visible_rect().encloses(child.get_global_rect()):
   settings_fit = false
   print("MENU_BOUNDS_DIAG: settings ", child.name, " ", child.get_global_rect(), " viewport=", root.get_visible_rect())
 check(settings_fit, "settings rows and Back fit within the 720p viewport")
 settings_menu.queue_free()
 await process_frame
 # Exercise the actual map-selection buttons and Escape scene transitions.
 var progress_before_previews := JSON.stringify(service.progress.snapshot())
 for preview_name: String in ["TUNG CHUNG", "HONG KONG", "NGONG PING"]:
  change_scene_to_file("res://scenes/main_menu.tscn")
  await process_frame
  await process_frame
  var menu: Node = current_scene
  menu.call("_previews")
  # Let the container lay out before checking that the actual button is on
  # screen; emitting a signal alone cannot prove mouse reachability.
  await process_frame
  await process_frame
  var chosen: Button = null
  for child: Node in menu.get("panel").get_children():
   if child is Button and child.text.contains(preview_name): chosen = child
  check(chosen != null and not chosen.disabled, preview_name + " preview button is clickable")
  if chosen:
   var bounds := chosen.get_global_rect()
   var viewport_bounds := root.get_visible_rect()
   if not viewport_bounds.encloses(bounds): print("MENU_BOUNDS_DIAG: ", preview_name, " ", bounds, " viewport=", viewport_bounds)
   check(viewport_bounds.encloses(bounds), preview_name + " preview button lies within the viewport")
   var back: Button = menu.get("panel").get_child(menu.get("panel").get_child_count() - 1)
   check(back.text == "BACK" and viewport_bounds.encloses(back.get_global_rect()), preview_name + " selection Back button lies within the viewport")
   chosen.pressed.emit()
   await process_frame
   await process_frame
   var preview: Node = current_scene
   check(preview != null and preview.scene_file_path.contains("preview"), preview_name + " preview loads from selection")
   if preview:
    var preview_player: HotelPlayer = preview.get("player")
    var before_preview := preview_player.global_position
    Input.action_press("move_forward")
    await create_timer(0.5).timeout
    Input.action_release("move_forward")
    check(preview_player.global_position.distance_to(before_preview) > 0.2, preview_name + " preview supports player movement")
    if preview_name == "TUNG CHUNG":
     var station_npcs: Array[HotelNpc] = preview.get("npcs")
     var exclusions: Array[RID] = [preview_player.get_rid()]
     for person: HotelNpc in station_npcs: exclusions.append(person.get_rid())
     var station_routes_clear := true
     for person: HotelNpc in station_npcs:
      var first: Vector3 = person.profile.schedule[0].destination + Vector3.UP * 0.8
      var second: Vector3 = person.profile.schedule[1].destination + Vector3.UP * 0.8
      var station_query := PhysicsRayQueryParameters3D.create(first, second)
      station_query.exclude = exclusions
      if not person.get_world_3d().direct_space_state.intersect_ray(station_query).is_empty(): station_routes_clear = false
     check(station_routes_clear, "station scripted routes avoid solid architecture")
     var passenger: HotelNpc = station_npcs[0]
     var passenger_start := passenger.global_position
     await create_timer(0.8).timeout
     check(passenger.global_position.distance_to(passenger_start) > 0.2, "station passenger advances along a local route")
     for person: HotelNpc in station_npcs: person.collision_layer = 0
     preview_player.global_position = Vector3(19,0.05,3)
     preview_player.rotation.y = 0
     preview_player.velocity = Vector3.ZERO
     await physics_frame
     Engine.time_scale = 2.0
     Input.action_press("move_back")
     await create_timer(2.6).timeout
     Input.action_release("move_back")
     Engine.time_scale = 1.0
     print("PREVIEW_ROUTE_DIAG: station platform ", preview_player.global_position)
     check(preview_player.global_position.z > 8.5 and preview_player.global_position.z < 11.8, "station public platform approach is physically walkable")
    else:
     var preview_npcs: Array[HotelNpc] = preview.get("npcs")
     check(preview_npcs.size() >= 3, preview_name + " preview includes local visitors")
     var visitor := preview_npcs[0]
     var visitor_start := visitor.global_position
     await create_timer(1.0).timeout
     check(visitor.global_position.distance_to(visitor_start) > 0.2, preview_name + " visitor follows its open public-space route")
     var query := PhysicsRayQueryParameters3D.create(visitor.global_position + Vector3.UP * 0.8, visitor.profile.schedule[0].destination + Vector3.UP * 0.8)
     var excludes: Array[RID] = [preview_player.get_rid()]
     for actor: HotelNpc in preview_npcs: excludes.append(actor.get_rid())
     query.exclude = excludes
     check(visitor.get_world_3d().direct_space_state.intersect_ray(query).is_empty(), preview_name + " scripted route remains free of solid architecture")
     var all_routes_clear := true
     for person: HotelNpc in preview_npcs:
      var route_start: Vector3 = person.profile.schedule[0].destination + Vector3.UP * 0.8
      var route_end: Vector3 = person.profile.schedule[1].destination + Vector3.UP * 0.8
      var route_query := PhysicsRayQueryParameters3D.create(route_start, route_end)
      route_query.exclude = excludes
      if not person.get_world_3d().direct_space_state.intersect_ray(route_query).is_empty(): all_routes_clear = false
     check(all_routes_clear, preview_name + " all scripted visitor routes remain clear of solid scenery")
     if preview_name == "HONG KONG":
      preview_player.global_position = Vector3(8.4,0.05,0)
      preview_player.rotation.y = 0
      preview_player.velocity = Vector3.ZERO
      await physics_frame
      Input.action_press("move_right")
      await create_timer(3.6).timeout
      Input.action_release("move_right")
      print("CITY_WALKWAY_DIAG: ", preview_player.global_position)
      check(preview_player.global_position.x > 15.0 and preview_player.global_position.y > 2.0, "city preview raised walkway is physically reachable")
      for actor: HotelNpc in preview_npcs: actor.collision_layer = 0
      preview_player.global_position = Vector3(0,0.05,0)
      preview_player.velocity = Vector3.ZERO
      await physics_frame
      Engine.time_scale = 2.0
      Input.action_press("move_left")
      await create_timer(4.6).timeout
      Input.action_release("move_left")
      print("PREVIEW_ROUTE_DIAG: city west ", preview_player.global_position)
      check(preview_player.global_position.x < -10.0, "city western district connects physically to the central street")
      Input.action_press("move_right")
      await create_timer(4.6).timeout
      Input.action_release("move_right")
      Engine.time_scale = 1.0
      check(preview_player.global_position.x > -2.0, "city central street is reachable on the return route")
     else:
      check(preview.find_child("MountainTerrain", true, false) != null and preview.find_child("TreeCanopies", true, false) != null, "mountain has physical rolling terrain and batched trees")
      var landmark := preview.find_child("ScenicBuddhaLandmark", true, false) as Node3D
      var landmark_is_scenic := landmark != null and landmark.scale.x > 1.0
      if landmark:
       for part: Node in landmark.find_children("*", "", true, false):
        if part is Interactable: landmark_is_scenic = false
      check(landmark_is_scenic, "public landmark has monumental scale and no target interaction")
      for actor: HotelNpc in preview_npcs: actor.collision_layer = 0
      preview_player.global_position = Vector3(9,0.05,-8)
      preview_player.rotation.y = 0
      preview_player.velocity = Vector3.ZERO
      await physics_frame
      Engine.time_scale = 2.0
      Input.action_press("move_right")
      await create_timer(6.5).timeout
      Input.action_release("move_right")
      print("PREVIEW_ROUTE_DIAG: mountain slope ", preview_player.global_position)
      check(preview_player.global_position.x > 23.0 and preview_player.global_position.y > 0.7, "mountain terrain is physically walkable uphill")
      Input.action_press("move_left")
      await create_timer(6.5).timeout
      Input.action_release("move_left")
      Engine.time_scale = 1.0
      check(preview_player.global_position.x < 12.0 and preview_player.global_position.y < 0.4, "mountain terrain is physically walkable back down")
      preview_player.global_position = Vector3(-9,0.05,-8)
      preview_player.velocity = Vector3.ZERO
      await physics_frame
      Engine.time_scale = 2.0
      Input.action_press("move_left")
      await create_timer(6.5).timeout
      Input.action_release("move_left")
      print("PREVIEW_ROUTE_DIAG: mountain west slope ", preview_player.global_position)
      check(preview_player.global_position.x < -23.0 and preview_player.global_position.y > 0.7, "opposite mountain slope is physically walkable uphill")
      Input.action_press("move_right")
      await create_timer(6.5).timeout
      Input.action_release("move_right")
      Engine.time_scale = 1.0
      check(preview_player.global_position.x > -12.0 and preview_player.global_position.y < 0.4, "opposite mountain slope is physically walkable back down")
    var exit_event := InputEventAction.new()
    exit_event.action = "release_mouse"
    exit_event.pressed = true
    preview.call("_unhandled_input", exit_event)
    await process_frame
    await process_frame
    var returned := current_scene != null and current_scene.scene_file_path == "res://scenes/main_menu.tscn"
    if returned:
     returned = current_scene.get("panel").get_child(0).text == "MISSION SELECTION"
    check(returned, preview_name + " Escape returns to mission selection")
 check(JSON.stringify(service.progress.snapshot()) == progress_before_previews, "exploration previews leave campaign progression unchanged")
 if current_scene != null:
  current_scene.queue_free()
  current_scene = null
 service.active_mission = ""
 service.progress.restore(saved_progress)
 service.campaign_path = saved_path
 for suffix: String in ["", ".bak", ".tmp"]:
  if FileAccess.file_exists(isolated_path + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(isolated_path + suffix))
 await process_frame
 print("RESULT: %d checks, %d failures" % [checks, failures.size()])
 quit(0 if failures.is_empty() else 1)
