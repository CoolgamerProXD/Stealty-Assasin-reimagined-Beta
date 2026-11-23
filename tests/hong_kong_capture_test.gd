extends SceneTree
## Scripted virtual-display captures, not a human playthrough or art signoff.
var failures := 0
var checks := 0
var output := ""
func _initialize() -> void:
 call_deferred("run")
func check(condition: bool, text: String) -> void:
 checks += 1
 if condition: print("HKVIS PASS: ", text)
 else:
  failures += 1
  printerr("HKVIS FAIL: ", text)
func capture(name: String) -> void:
 for frame: int in range(4): await process_frame
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image()
 image.save_png(output.path_join(name + ".png"))
 var thumb := image.duplicate() as Image
 thumb.resize(320,180)
 thumb.save_jpg(output.path_join(name + "_thumb.jpg"),0.48)
# Short fixed-view software-renderer samples, not target-device benchmarks.
func sample_quality(service: Node, location: String, quality: String) -> void:
 service.settings["graphics"] = quality
 service.apply_settings()
 for frame: int in range(10): await process_frame
 var samples: Array[float] = []
 var previous := Time.get_ticks_usec()
 for frame: int in range(30):
  await process_frame
  var now := Time.get_ticks_usec()
  samples.append(float(now-previous)/1000.0)
  previous = now
 samples.sort()
 var total := 0.0
 for value: float in samples: total += value
 var mean := total/float(samples.size())
 print("HKPERF: %s %s frames=30 mean_ms=%.3f p95_ms=%.3f fps=%.2f" % [location,quality,mean,samples[28],1000.0/maxf(mean,0.001)])

func _progress_for(service: Node, operation_id: String) -> void:
 var ordered := ["tung_chung","the_streets","the_district","the_harbour","ngong_ping","house"]
 var target_ids := {"tung_chung":["usb_robber","constance_operative"],"the_streets":["market_vendor"],"the_district":["corporate_fixer"],"the_harbour":["harbour_businessman"],"ngong_ping":["field_coordinator"],"house":[]}
 var completed: Array[String] = ["initiation"]
 var targets: Dictionary = {}
 var keys: Array[String] = []
 if operation_id == "hong_kong_sandbox":
  operation_id = "ngong_ping"
 var current := ordered.find(operation_id)
 for index: int in range(maxi(0,current)):
  var mission_id: String = ordered[index]
  completed.append(mission_id)
  targets[mission_id] = target_ids[mission_id]
  keys.append("key_%02d" % (index + 1))
 service.progress.restore({"schema_version":2,"completed":completed,"completed_targets":targets,"recovered_keys":keys})

func run() -> void:
 output = OS.get_environment("TEST_SCREENSHOT_DIR")
 if output.is_empty(): output = "user://captures"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
 root.size = Vector2i(1280,720)
 var service := root.get_node("Campaign")
 var old_settings: Dictionary = service.settings.duplicate(true)
 var old_progress: Dictionary = service.progress.snapshot()
 var old_active: String = service.active_mission
 var old_campaign_path: String = service.campaign_path
 var scratch_campaign_path := "user://hk_capture_%d_campaign.json" % Time.get_ticks_usec()
 service.campaign_path = scratch_campaign_path
 var ids: Array[String] = ["tung_chung","the_streets","the_district","the_harbour","hong_kong_sandbox","ngong_ping","house"]
 for id: String in ids:
  _progress_for(service,id)
  service.active_mission = id
  var world: Node3D = load("res://scenes/mission_" + id + ".tscn").instantiate()
  root.add_child(world)
  await process_frame
  await physics_frame
  var intro: Camera3D = world.get("intro_camera")
  check(intro.current and world.get("intro_active"),id + " entry camera is active")
  if id != "ngong_ping": check(world.get("has_establishing"),id + " opens on location before cutting to target")
  check(root.get_visible_rect().encloses((world.get("skip_button") as Button).get_global_rect()),id + " skip button fits at 720p")
  await capture("hk_intro_" + id)
  world.call("_end_intro")
  var player: HotelPlayer = world.get("player")
  check(player.camera.current and player.is_physics_processing(),id + " gameplay camera resumes")
  check(root.get_visible_rect().encloses((world.get("hud") as Control).get_global_rect()),id + " objective HUD fits at 720p")
  if id == "tung_chung":
   var target: HotelNpc = world.get("target")
   for npc: HotelNpc in world.get("npc_list"): npc.set_physics_process(false)
   player.global_position = target.global_position + Vector3(0,0,4)
   player.rotation.y = 0.0
   player.velocity = Vector3.ZERO
   player.aiming = true
   player.equipment.selected = "training_sidearm"
   player.equipment.charges = 5
   for frame: int in range(3): await physics_frame
   player.camera.look_at(target.global_position + Vector3.UP,Vector3.UP)
   world.call("_fire")
   check(world.get("target_complete") and not world.get("key_secured") and player.equipment.charges == 4,"Tung Chung target tag does not collect its physical key")
   check(float((world.get("reticle") as Control).get("hit_timer")) > 0.0,"Tung Chung shot displays hit confirmation")
   player.aiming = false
  var shot := Camera3D.new()
  world.add_child(shot)
  var focus: Vector3 = (world.get("target") as HotelNpc).global_position + Vector3.UP
  if id == "house":
   shot.global_position = Vector3(0,2.4,-3)
   shot.look_at(Vector3(0,1.0,-8),Vector3.UP)
  elif id == "ngong_ping":
   shot.global_position = Vector3(0,8,8)
   shot.look_at(Vector3(0,11,-29),Vector3.UP)
  elif id == "tung_chung":
   world.call("_board_train")
   shot.global_position = Vector3(19,2.1,18)
   shot.look_at(Vector3(19,1.2,34),Vector3.UP)
  else:
   shot.global_position = Vector3(0,6,28)
   shot.look_at(Vector3(0,1,-15),Vector3.UP)
  shot.make_current()
  await capture("hk_play_" + id)
  if id == "house":
   for npc: HotelNpc in world.get("npc_list"): npc.set_physics_process(false)
   player.set_physics_process(false)
   var safe: Node3D = world.get("house_safe_marker")
   player.global_position = safe.global_position + Vector3(0,0,1.5)
   world.call("_interact")
   check(service.progress.house_code_recovered and service.progress.house_code.length() == 70,"physical House safe records the independent 70-digit code")
   await capture("hk_house_safe_code")
   var house_exit: Node3D = world.get("exit_marker")
   player.global_position = house_exit.global_position + Vector3(0,0,1.0)
   world.call("_interact")
   check(service.progress.completed.has("house") and world.get("extraction_active"),"House extraction follows code recovery and unlocks only the decryption transition")
  if id == "hong_kong_sandbox":
   var targets: Array = world.get("sandbox_targets")
   var records: Array = world.get("sandbox_target_data")
   var people: Array = world.get("npc_list")
   for npc: HotelNpc in people: npc.set_physics_process(false)
   var city: Node3D = world.get("scene")
   # Original procedural district asset and all operation actors share this scene.
   shot.global_position = Vector3(-58,5,-4)
   shot.look_at(Vector3(-63,1,-17),Vector3.UP)
   await capture("hk_district_market")
   shot.global_position = Vector3(58,6,-4)
   shot.look_at(Vector3(63,1,-17),Vector3.UP)
   await capture("hk_district_commercial")
   # Walk-in lobby and executive floors are all part of the same local build.
   shot.global_position = Vector3(17,5,-72)
   shot.look_at(Vector3(17,3,-83),Vector3.UP)
   await capture("hk_skyscraper_lobby")
   shot.global_position = Vector3(17,14,-78)
   shot.look_at(Vector3(17,13,-83),Vector3.UP)
   await capture("hk_skyscraper_interior")
   # Instinct reveals each active target through nearby geometry in red.
   player.instinct_active = true
   for index: int in range(targets.size()):
    var npc := targets[index] as HotelNpc
    var target_capture_id := str(records[index]["id"])
    player.global_position = npc.global_position + Vector3(0,0,4.0)
    shot.global_position = npc.global_position + Vector3(0,2.3,5.0)
    shot.look_at(npc.global_position + Vector3.UP,Vector3.UP)
    world.call("_process",0.0)
    await capture("hk_instinct_target_" + target_capture_id)
   player.instinct_active = false
   # Local, in-person security state is shown independently of distant guards.
   var local_guard: HotelNpc = null
   for npc: HotelNpc in people:
    if npc.profile.occupation == "security":
     local_guard = npc
     break
   if local_guard:
    player.global_position = local_guard.global_position + Vector3(0,0,3.5)
    local_guard.suspicion = 72.0
    local_guard.set_state("investigating")
    shot.global_position = player.global_position + Vector3(0,3.0,4.0)
    shot.look_at(local_guard.global_position + Vector3.UP,Vector3.UP)
   world.call("_process",0.0)
   await capture("hk_awareness_local")
   # Stage a completed-state HUD without treating this capture as progression.
   var flags: Dictionary = world.get("sandbox_target_completed")
   for index: int in range(targets.size()):
    flags[str(records[index]["id"])] = true
    (targets[index] as HotelNpc).complete_objective(false)
   for key_id: String in ["key_02","key_03","key_04"]:
    if not service.progress.recovered_keys.has(key_id): service.progress.recovered_keys.append(key_id)
   world.set("target_complete",true)
   world.call("_process",0.0)
   check((world.get("awareness_label") as Label).visible and (world.get("hud") as Control).visible,"sandbox awareness and campaign tracker are visible")
   await capture("hk_completed_hud")
   service.progress.restore(old_progress)
   shot.queue_free()
  if id in ["tung_chung","ngong_ping"]:
   for quality: String in ["LOW","MEDIUM","HIGH"]: await sample_quality(service,id,quality)
  world.queue_free()
  await process_frame
 service.settings = old_settings
 service.progress.restore(old_progress)
 service.active_mission = old_active
 service.campaign_path = old_campaign_path
 for suffix: String in ["", ".bak", ".tmp"]:
  var path := scratch_campaign_path + suffix
  if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 service.apply_settings()
 print("HKVIS RESULT: %d checks, %d failures" % [checks,failures])
 quit(0 if failures == 0 else 1)
