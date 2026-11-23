extends SceneTree
## Godot 4.4.1 integration checks for Assignment 004. Automated only; this is
## not a replacement for interactive playtesting or the Windows export.
var checks := 0
var failures := 0

func _initialize() -> void:
 call_deferred("run")

func check(condition: bool, text: String) -> void:
 checks += 1
 if condition: print("HK PASS: ", text)
 else:
  failures += 1
  printerr("HK FAIL: ", text)

func near_player(world: Node3D, point: Vector3) -> void:
 var player: HotelPlayer = world.get("player")
 player.global_position = point + Vector3(0,0,1.15)
 player.velocity = Vector3.ZERO
 await physics_frame

func run() -> void:
 var service: Node = root.get_node("Campaign")
 var old_path: String = service.campaign_path
 var old_active: String = service.active_mission
 var old_progress: Dictionary = service.progress.snapshot()
 var temp := "user://assassin_assignment004_%d" % Time.get_ticks_usec()
 service.campaign_path = temp + "_campaign.json"

 var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/campaign.json"))
 var configured := CampaignProgress.new()
 check(configured.configure(definition), "campaign definition configures")
 var campaign_ids: Array[String] = []
 for entry: Dictionary in configured.missions: campaign_ids.append(str(entry["id"]))
 check(campaign_ids == ["initiation","meridian","tung_chung","hong_kong_sandbox","ngong_ping"], "one selectable Hong Kong city operation replaces the three legacy entries")
 check(configured.mission("the_streets").is_empty() and configured.mission("the_district").is_empty() and configured.mission("the_harbour").is_empty(), "legacy city IDs are not selectable campaign missions")

 configured.restore({"completed":["initiation","tung_chung","the_streets","the_district","the_harbour"],"recovered_keys":["key_01"]})
 check(configured.completed.has("tung_chung") and not configured.completed.has("hong_kong_sandbox"), "legacy progress migrates without silently completing sandbox targets")
 check(not configured.recovered_keys.has("key_02") and not configured.recovered_keys.has("key_03") and not configured.recovered_keys.has("key_04"), "legacy mission completion alone never invents physical city keys")
 check(not configured.usb_ready(), "legacy city completion alone cannot unlock decryption")

 service.progress.restore({})
 check(service.progress.mark_complete("initiation"), "Initiation remains the first required operation")
 check(service.progress.secure_key("tung_chung","key_01") and service.progress.mark_complete("tung_chung"), "Operation 01 preserves its physical Key 01 prerequisite")
 check(service.progress.is_unlocked("hong_kong_sandbox"), "Operation 01 unlocks the unified city sandbox")
 service.active_mission = "hong_kong_sandbox"
 check(not service.progress.secure_key("hong_kong_sandbox","key_01"), "sandbox cannot re-award Operation 01's key")
 check(service.progress.secure_key("hong_kong_sandbox","key_02") and service.progress.secure_key("hong_kong_sandbox","key_03") and service.progress.secure_key("hong_kong_sandbox","key_04"), "the sandbox accepts only its three configured physical keys")
 check(not service.progress.completed.has("hong_kong_sandbox"), "key recovery alone never marks the sandbox operation complete")
 service.progress.recovered_keys.erase("key_02")
 service.progress.recovered_keys.erase("key_03")
 service.progress.recovered_keys.erase("key_04")
 service.persist()

 var awareness_guard := HotelNpc.new()
 awareness_guard.profile = NpcProfile.new()
 awareness_guard.profile.occupation = "security"
 root.add_child(awareness_guard)
 awareness_guard.set_physics_process(false)
 awareness_guard.warn_trespass(Vector3.ZERO,Vector3.LEFT,"staff")
 check(awareness_guard.state == "warning" and is_equal_approx(awareness_guard.warning_remaining,1.5), "ordinary security warning uses the readable 1.5-second grace period")
 awareness_guard.tick_trespass(1.5,true)
 check(awareness_guard.state == "alerted", "local security escalates after the ordinary grace period")
 awareness_guard.warning_cooldown = 0.0
 awareness_guard.set_state("idle")
 awareness_guard.warn_trespass(Vector3.ZERO,Vector3.LEFT,"public",true)
 check(awareness_guard.state == "warning" and is_equal_approx(awareness_guard.warning_remaining,0.5), "visible sidearm warning uses the short 0.5-second threshold")
 awareness_guard.queue_free()

 # Tung Chung has two distinct, explicitly completable targets. Talking to
 # either actor or incapacitating them must not satisfy either objective or
 # award the physically carried key.
 service.progress.restore({"completed":["initiation"],"recovered_keys":[]})
 service.active_mission = "tung_chung"
 var station := load("res://scenes/mission_tung_chung.tscn").instantiate() as Node3D
 root.add_child(station)
 await process_frame
 await process_frame
 for npc: HotelNpc in station.get("npc_list"): npc.set_physics_process(false)
 station.call("_skip_cinematic")
 var robber: HotelNpc = station.get("target")
 await near_player(station, robber.global_position)
 station.call("_interact")
 check(not station.get("target_complete") and not service.progress.recovered_keys.has("key_01"), "Robber dialogue cannot complete the target or award Key 01")
 robber.incapacitate(12.0)
 station.call("_interact")
 check(not station.get("target_complete"), "temporary Robber incapacitation is not target completion")
 var operative: HotelNpc = station.get("guard")
 await near_player(station, operative.global_position)
 station.call("_interact")
 check(not station.get("operative_complete"), "Constance's operative dialogue cannot complete that objective")
 station.set("target_complete", true)
 station.call("_secure_key")
 check(not service.progress.recovered_keys.has("key_01"), "Key 01 stays unavailable until both distinct Tung Chung targets are complete")
 # A legacy checkpoint cannot restore a finished pursuit or key while omitting
 # the newly required operative objective.
 service.progress.recovered_keys.append("key_01")
 var legacy_station_save := temp + "_legacy_station.json"
 station.set("save_path", legacy_station_save)
 SaveStore.write(legacy_station_save,{"mission_id":"tung_chung","target_complete":true,"key_id":"key_01","key_secured":true,"train_stage":"aboard"})
 station.call("load_game")
 check(not station.get("operative_complete") and not station.get("key_secured") and station.get("train_stage") != "aboard", "legacy Tung Chung checkpoints cannot bypass the operative target prerequisite")
 service.progress.recovered_keys.erase("key_01")
 station.queue_free()
 await process_frame

 service.progress.restore({"completed":["initiation","tung_chung"],"recovered_keys":["key_01"]})
 service.active_mission = "hong_kong_sandbox"
 var world := load("res://scenes/mission_hong_kong_sandbox.tscn").instantiate() as Node3D
 root.add_child(world)
 await process_frame
 await process_frame
 check(world.get("operation_id") == "hong_kong_sandbox", "sandbox scene boots as one mission")
 var targets: Array = world.get("sandbox_targets")
 var keys: Array = world.get("sandbox_key_markers")
 var intel: Array = world.get("sandbox_intel_markers")
 var people: Array = world.get("npc_list")
 check(targets.size() == 3 and keys.size() == 3 and intel.size() == 3, "three physical target actors, keys and optional intelligence markers exist")
 var city: Node3D = world.get("scene")
 check(city.find_child("District_the_streets",true,false) != null and city.find_child("District_the_district",true,false) != null and city.find_child("District_the_harbour",true,false) != null, "all three distinct neighbourhoods are present in the same world scene")
 check(city.find_child("NeighbourhoodStreetNavigation",true,false) != null, "district navigation is instantiated inside the shared city scene")
 check(city.find_child("CorporateFloorNavigation_4",true,false) != null and not city.find_children("*","DestructibleGlass",true,false).is_empty(), "harbour skyscraper has an accessible upper floor and collision-backed breakable glazing")
 for npc: HotelNpc in people: npc.set_physics_process(false)
 world.call("_skip_cinematic")
 var target: HotelNpc = targets[0]
 await near_player(world,target.global_position)
 world.call("_interact")
 check(not bool(world.get("sandbox_target_completed")["loan_shark"]), "target dialogue reveals narrative but never completes the objective")
 target.incapacitate(12.0)
 world.call("_interact")
 check(not bool(world.get("sandbox_target_completed")["loan_shark"]), "temporary incapacitation never satisfies a target objective")
 check(not world.call("_complete_sandbox_target",target), "assessment tag rejects an incapacitated target")
 target.stunned_time = 0.0
 target.set_state("returning")
 check(bool(world.call("_complete_sandbox_target",target)), "non-graphic assessment tag permanently completes an active target")
 check(not world.call("_complete_sandbox_target",target), "completed target state cannot be awarded twice")

 # A physical pickup is an in-world interaction and persists the exact key ID.
 var first_key: Node3D = keys[0]
 await near_player(world,first_key.global_position)
 world.call("_interact")
 check(service.progress.recovered_keys.has("key_02") and not first_key.visible, "Key 02 is physically collected from its placed marker")
 var exit: Node3D = world.get("exit_marker")
 await near_player(world,exit.global_position)
 world.call("_interact")
 check(not service.progress.completed.has("hong_kong_sandbox") and not world.get("extraction_active"), "extraction stays locked with mandatory targets and keys missing")

 # Checkpoint schema stores explicit target IDs; legacy booleans are ignored.
 world.set("save_path",temp + "_sandbox.json")
 world.call("save_game")
 var saved: Dictionary = SaveStore.read(temp + "_sandbox.json")
 check(saved.get("sandbox_targets_completed",[]) == ["loan_shark"] and saved.get("sandbox_intel_completed",[]) is Array, "checkpoint records only explicit sandbox target and intelligence IDs")
 SaveStore.write(temp + "_sandbox.json",{"mission_id":"hong_kong_sandbox","target_complete":true,"key_secured":true,"key_id":"key_02"})
 world.set("sandbox_target_completed",{"loan_shark":false,"corporate_fixer":false,"harbour_businessman":false})
 world.call("load_game")
 check(not bool(world.get("sandbox_target_completed")["loan_shark"]), "legacy single-target checkpoint flags cannot silently migrate target completion")
 check(service.progress.recovered_keys.has("key_02"), "a key explicitly stored in campaign recovery remains preserved")

 world.queue_free()
 await process_frame
 service.campaign_path = old_path
 service.active_mission = old_active
 service.progress.restore(old_progress)
 for path: String in [temp + "_campaign.json",temp + "_campaign.json.bak",temp + "_campaign.json.tmp",temp + "_sandbox.json",temp + "_sandbox.json.bak",temp + "_sandbox.json.tmp",temp + "_legacy_station.json",temp + "_legacy_station.json.bak",temp + "_legacy_station.json.tmp"]:
  if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("HK RESULT: %d checks, %d failures" % [checks,failures])
 quit(0 if failures == 0 else 1)
