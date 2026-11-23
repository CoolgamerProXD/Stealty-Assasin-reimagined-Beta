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
 check(campaign_ids == ["initiation","tung_chung","the_streets","the_district","the_harbour","ngong_ping","house","meridian"], "campaign follows the five-key sequence, then House, with Meridian retained as a late optional replay")
 check(configured.mission("the_streets").get("key_id", "") == "key_02" and configured.mission("the_district").get("key_id", "") == "key_03" and configured.mission("the_harbour").get("key_id", "") == "key_04", "each allied city operation owns exactly one sequential key")

 configured.restore({"completed":["initiation","tung_chung","the_streets","the_district","the_harbour"],"recovered_keys":["key_01"]})
 check(configured.completed.has("initiation") and not configured.completed.has("tung_chung"), "legacy target-mission completion is not trusted without the new objective schema")
 check(configured.recovered_keys.has("key_01") and not configured.recovered_keys.has("key_02") and not configured.recovered_keys.has("key_03") and not configured.recovered_keys.has("key_04"), "legacy saves preserve only explicitly recovered physical keys")
 check(not configured.usb_ready(), "legacy city completion alone cannot unlock decryption")

 service.progress.restore({})
 check(service.progress.mark_complete("initiation"), "Initiation remains the first required operation")
 check(service.progress.secure_key("tung_chung","key_01") and not service.progress.mark_complete("tung_chung"), "a key alone cannot complete Tung Chung without both target records")
 check(service.progress.record_target_completion("tung_chung","usb_robber") and service.progress.record_target_completion("tung_chung","constance_operative") and service.progress.mark_complete("tung_chung"), "Operation 01 requires explicit completion records for the Robber and Constance's operative")
 check(service.progress.is_unlocked("the_streets"), "Operation 01 unlocks Streets, not a combined city sandbox")
 check(service.progress.secure_key("the_streets","key_02") and service.progress.record_target_completion("the_streets","market_vendor") and service.progress.mark_complete("the_streets"), "Streets requires a completed vendor objective and physical Key 02")
 check(service.progress.is_unlocked("the_district") and service.progress.secure_key("the_district","key_03") and service.progress.record_target_completion("the_district","corporate_fixer") and service.progress.mark_complete("the_district"), "Commercial District requires the fixer and physical Key 03")
 check(service.progress.is_unlocked("the_harbour") and service.progress.secure_key("the_harbour","key_04") and service.progress.record_target_completion("the_harbour","harbour_businessman") and service.progress.mark_complete("the_harbour"), "Harbour requires the businessman and physical Key 04")
 check(service.progress.is_unlocked("ngong_ping") and not service.progress.recovered_keys.has("key_05") and not service.progress.is_unlocked("house"), "House stays locked until Ngong Ping and Key 05")
 check(service.progress.secure_key("ngong_ping","key_05") and service.progress.record_target_completion("ngong_ping","field_coordinator") and service.progress.mark_complete("ngong_ping"), "Ngong Ping alone provides Key 05 and completes the field-coordinator objective")
 check(service.progress.is_unlocked("house") and not service.progress.mark_complete("house"), "all five keys unlock House but the safe code remains mandatory")
 var code_fixture := "8282276899555634186801128061495577508192436694724980912146277806558513"
 check(code_fixture.length() == 70 and not service.progress.record_house_code(code_fixture.substr(0,69)), "House rejects a truncated safe code")
 check(service.progress.record_house_code(code_fixture) and service.progress.mark_complete("house"), "the independent 70-digit safe code is persisted and required to finish House")
 check(Campaign.acknowledge_usb_decryption() and Campaign.mark_betrayal_seen(), "decryption and the betrayal record are gated behind all five keys and House completion")
 var objective_copy := CampaignProgress.new()
 objective_copy.configure(definition)
 objective_copy.restore(service.progress.snapshot())
 check(objective_copy.completed_targets.get("tung_chung",[]).has("constance_operative") and objective_copy.completed.has("the_harbour") and objective_copy.completed.has("house") and objective_copy.house_code.length() == 70 and objective_copy.betrayal_seen, "explicit targets, House code and post-decryption betrayal state survive campaign save restoration")
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

 service.progress.restore({"schema_version":2,"completed":["initiation","tung_chung"],"completed_targets":{"tung_chung":["usb_robber","constance_operative"]},"recovered_keys":["key_01"]})
 service.active_mission = "the_streets"
 var world := load("res://scenes/mission_the_streets.tscn").instantiate() as Node3D
 root.add_child(world)
 await process_frame
 await process_frame
 check(world.get("operation_id") == "the_streets", "Streets boots as its own selectable mission")
 var city: Node3D = world.get("scene")
 check(city.find_child("District_the_streets",true,false) != null and city.find_child("District_the_district",true,false) != null and city.find_child("District_the_harbour",true,false) != null, "district extensions remain connected in a shared explorable city")
 check(city.find_child("NeighbourhoodStreetNavigation",true,false) != null, "connected street navigation is instantiated")
 check(city.find_child("CorporateFloorNavigation_4",true,false) != null and not city.find_children("*","DestructibleGlass",true,false).is_empty(), "city retains an accessible upper floor and collision-backed glazing")
 var people: Array = world.get("npc_list")
 for npc: HotelNpc in people: npc.set_physics_process(false)
 world.call("_skip_cinematic")
 var target: HotelNpc = world.get("target")
 await near_player(world,target.global_position)
 world.call("_interact")
 check(not world.get("target_complete") and not service.progress.recovered_keys.has("key_02"), "market target dialogue cannot complete the objective or award Key 02")
 target.incapacitate(12.0)
 world.call("_interact")
 check(not world.get("target_complete"), "temporary target incapacitation is not objective completion")
 world.call("_secure_key")
 check(not service.progress.recovered_keys.has("key_02"), "physical key remains locked until the target is permanently completed")
 var key_marker: Node3D = world.get("key_marker")
 check(key_marker.get_parent() == world.get("guard"), "Key 02 is represented by a separate physical marker on the escort")
 # Model the successful tag state to verify the distinct pickup interaction.
 target.stunned_time = 0.0
 target.set_state("returning")
 world.set("target_complete",true)
 var guard: HotelNpc = world.get("guard")
 await near_player(world,key_marker.global_position)
 world.call("_interact")
 check(service.progress.recovered_keys.has("key_02") and not key_marker.visible, "Key 02 is collected only by interacting with its physical marker")
 var exit: Node3D = world.get("exit_marker")
 await near_player(world,exit.global_position)
 world.set("target_complete",false)
 world.call("_interact")
 check(not service.progress.completed.has("the_streets") and not world.get("extraction_active"), "district extraction remains locked until target completion")
 world.queue_free()
 await process_frame

 service.campaign_path = old_path
 service.active_mission = old_active
 service.progress.restore(old_progress)
 for path: String in [temp + "_campaign.json",temp + "_campaign.json.bak",temp + "_campaign.json.tmp",temp + "_legacy_station.json",temp + "_legacy_station.json.bak",temp + "_legacy_station.json.tmp"]:
  if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("HK RESULT: %d checks, %d failures" % [checks,failures])
 quit(0 if failures == 0 else 1)
