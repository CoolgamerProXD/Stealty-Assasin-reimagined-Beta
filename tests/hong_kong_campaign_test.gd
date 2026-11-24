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

func tag_live_target(world: Node3D, npc: HotelNpc) -> void:
 var player: HotelPlayer = world.get("player")
 for other: HotelNpc in world.get("npc_list"):
  other.set_physics_process(false)
 player.set_physics_process(false)
 player.set_process_unhandled_input(false)
 player.global_position = npc.global_position + Vector3(0,0,4.0)
 player.velocity = Vector3.ZERO
 player.stance_height = 1.8
 player.aiming = true
 player.equipment.selected = "training_sidearm"
 player.equipment.charges = 5
 player.camera.make_current()
 player.camera.look_at(npc.global_position + Vector3.UP*1.1,Vector3.UP)
 for frame: int in range(3): await physics_frame
 player.camera.look_at(npc.global_position + Vector3.UP*1.1,Vector3.UP)
 world.call("_fire")
 await physics_frame

func recover_live_key(world: Node3D) -> bool:
 var player: HotelPlayer = world.get("player")
 var marker: Node3D = world.get("key_marker")
 if marker == null: return false
 player.global_position = marker.global_position + Vector3(1.25,0,0)
 player.velocity = Vector3.ZERO
 player.camera.look_at(marker.global_position + Vector3.UP*0.65,Vector3.UP)
 for frame: int in range(3): await physics_frame
 for attempt: int in range(3):
  world.call("_interact")
  if bool(world.get("key_secured")): return true
  await physics_frame
 return false

func complete_live_operation(service: Node, operation_id: String, target_id: String, checkpoint_path: String) -> bool:
 service.active_mission = operation_id
 var world := load("res://scenes/mission_" + operation_id + ".tscn").instantiate() as Node3D
 root.add_child(world)
 await process_frame
 await process_frame
 world.call("_skip_cinematic")
 var target: HotelNpc = world.get("target")
 for npc: HotelNpc in world.get("npc_list"): npc.set_physics_process(false)
 await near_player(world,target.global_position)
 world.call("_interact")
 check(not bool(world.get("target_complete")) and not service.progress.completed_targets.get(operation_id,[]).has(target_id),operation_id + " target dialogue is intelligence, not completion")
 await tag_live_target(world,target)
 check(bool(world.get("target_complete")) and target.objective_completed and service.progress.completed_targets.get(operation_id,[]).has(target_id),operation_id + " target is completed through the playable assessment ray and saved objective")
 check(await recover_live_key(world) and bool(world.get("key_secured")) and service.progress.recovered_keys.has(str(service.progress.mission(operation_id).get("key_id",""))),operation_id + " physical key is collected through the in-game interaction")
 world.set("save_path",checkpoint_path)
 world.call("save_game")
 var checkpoint := SaveStore.read(checkpoint_path)
 check(checkpoint.get("target_complete",false) and checkpoint.get("key_secured",false),operation_id + " mission checkpoint stores target and collected-key state")
 world.set("target_complete",false)
 world.set("key_secured",false)
 world.call("load_game")
 check(bool(world.get("target_complete")) and bool(world.get("key_secured")),operation_id + " loading checkpoint restores campaign-verified target and key progress")
 var persisted := CampaignProgress.new()
 persisted.configure(JSON.parse_string(FileAccess.get_file_as_string("res://resources/campaign.json")))
 persisted.restore(SaveStore.read(service.campaign_path))
 check(persisted.completed_targets.get(operation_id,[]).has(target_id) and persisted.recovered_keys.has(str(service.progress.mission(operation_id).get("key_id",""))),operation_id + " campaign save independently preserves target ID and physical key")
 var completed: bool = service.complete(operation_id,0)
 check(completed and service.progress.completed.has(operation_id),operation_id + " extraction prerequisite accepts completed target and physical key")
 world.queue_free()
 await process_frame
 return completed

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
 check(service.acknowledge_usb_decryption() and service.progress.usb_decryption_seen and not service.progress.betrayal_seen, "decryption opens only after all five keys and House completion; the rescue is still pending")
 var objective_copy := CampaignProgress.new()
 objective_copy.configure(definition)
 objective_copy.restore(service.progress.snapshot())
 check(objective_copy.completed_targets.get("tung_chung",[]).has("constance_operative") and objective_copy.completed.has("the_harbour") and objective_copy.completed.has("house") and objective_copy.house_code.length() == 70 and objective_copy.usb_decryption_seen and not objective_copy.betrayal_seen, "explicit targets, House code and pending post-decryption state survive campaign save restoration")
 service.persist()
 var keys_before_rescue: Array[String] = service.progress.recovered_keys.duplicate()
 var targets_before_rescue: Dictionary = service.progress.completed_targets.duplicate(true)
 var post_story := load("res://scenes/post_usb_betrayal.tscn").instantiate() as Node3D
 root.add_child(post_story)
 await process_frame
 await process_frame
 check(not post_story.get("waiting_for_rescue") and post_story.get("camera").is_current() and not service.progress.betrayal_seen, "valid saved decryption state opens the interactive Ruby betrayal scene")
 post_story.set("waiting_for_rescue", true)
 var rescue_event := InputEventAction.new()
 rescue_event.action = "interact"
 rescue_event.pressed = true
 post_story.call("_unhandled_input", rescue_event)
 check(post_story.get("rescued") and service.progress.betrayal_seen and service.progress.recovered_keys == keys_before_rescue and service.progress.completed_targets == targets_before_rescue, "pressing E rescues Ruby and records betrayal without changing any target or key progress")
 await create_timer(4.1).timeout
 check(post_story.get("continue_button").visible and str(post_story.get("subtitles").text).contains("hunt the Covenant"), "post-rescue dialogue preserves the unresolved contents and begins the quiet hunt")
 post_story.queue_free()
 await process_frame

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
 await tag_live_target(station,operative)
 check(bool(station.get("operative_complete")) and service.progress.completed_targets.get("tung_chung",[]).has("constance_operative"), "Constance's real operative NPC is permanently completed by the playable assessment ray (message=%s; target=%s; operative=%s; guard=%s; charges=%s)" % [str(station.get("message")),str(station.get("target_complete")),str(station.get("operative_complete")),str(operative.state),str(station.get("player").equipment.charges)])
 robber.stunned_time = 0.0
 robber.set_state("idle")
 await tag_live_target(station,robber)
 check(bool(station.get("target_complete")) and service.progress.completed_targets.get("tung_chung",[]).has("usb_robber"), "the USB robber target is permanently completed through the live scene (message=%s; target=%s; operative=%s; robber=%s; charges=%s)" % [str(station.get("message")),str(station.get("target_complete")),str(station.get("operative_complete")),str(robber.state),str(station.get("player").equipment.charges)])
 station.call("_skip_cinematic")
 check(str(station.get("story_phase")).is_empty() and station.get("key_marker").get_parent() == station, "Ruby's pursuit handoff drops Key 01 into the station world")
 check(await recover_live_key(station) and service.progress.recovered_keys.has("key_01"), "Key 01 is physically recovered with the in-game interaction after both target records")
 var station_checkpoint := temp + "_station_checkpoint.json"
 station.set("save_path",station_checkpoint)
 station.call("save_game")
 var saved_station := SaveStore.read(station_checkpoint)
 check(saved_station.get("objective_schema",0) == 2 and saved_station.get("target_complete",false) and saved_station.get("operative_complete",false) and saved_station.get("key_secured",false), "Tung Chung checkpoint saves both mandatory targets and collected Key 01")
 station.call("load_game")
 check(bool(station.get("target_complete")) and bool(station.get("operative_complete")) and bool(station.get("key_secured")), "Tung Chung save/load restores both target states and physical key state")
 check(service.complete("tung_chung",0) and service.progress.completed.has("tung_chung"), "Tung Chung completes and unlocks Streets only after both targets and Key 01")
 # An old checkpoint cannot restore a finished pursuit or key while omitting
 # the newly required operative objective.
 service.progress.recovered_keys.append("key_01")
 var legacy_station_save := temp + "_legacy_station.json"
 station.set("save_path",legacy_station_save)
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
 check(city.find_child("District_the_streets",true,false) != null and city.find_child("District_the_district",true,false) == null and city.find_child("District_the_harbour",true,false) == null, "Streets loads its own distinct district without bundling the later operations")
 check(int(city.get_meta("city_facade_bays",0)) >= 150 and city.find_child("DistrictDetails",true,false) != null, "Hong Kong street blocks have articulated four-sided window bays, frames, sills and roof-edge structure")
 check(city.find_child("NeighbourhoodStreetNavigation",true,false) != null, "connected street navigation is instantiated")
 check(city.find_child("NeighbourhoodStreetNavigation",true,false) != null and city.find_children("*","DestructibleGlass",true,false).is_empty(), "Streets retains walkable public routes without preloading Harbour's tower")
 check(city.find_child("NeighbourhoodStreetNavigation",true,false) != null and city.find_children("*","DestructibleGlass",true,false).is_empty(), "Streets retains walkable public routes without preloading Harbour's tower")
 world.queue_free()
 await process_frame

 check(await complete_live_operation(service,"the_streets","market_vendor",temp + "_streets_checkpoint.json"),"mandatory market vendor, Key 02, save/load and operation completion work in the Streets mission")
 check(await complete_live_operation(service,"the_district","corporate_fixer",temp + "_district_checkpoint.json"),"mandatory corporate fixer, Key 03, save/load and operation completion work in the Commercial District mission")
 check(await complete_live_operation(service,"the_harbour","harbour_businessman",temp + "_harbour_checkpoint.json"),"mandatory businessman, Key 04, save/load and operation completion work in Harbour")
 check(await complete_live_operation(service,"ngong_ping","field_coordinator",temp + "_ngong_ping_checkpoint.json"),"mandatory field coordinator, Key 05, save/load and operation completion work in Ngong Ping before House")

 service.progress.restore({"schema_version":2,"completed":["initiation","tung_chung","the_streets","the_district"],"completed_targets":{"tung_chung":["usb_robber","constance_operative"],"the_streets":["market_vendor"],"the_district":["corporate_fixer"]},"recovered_keys":["key_01","key_02","key_03"]})
 service.active_mission = "the_harbour"
 var harbour_world := load("res://scenes/mission_the_harbour.tscn").instantiate() as Node3D
 root.add_child(harbour_world)
 await process_frame
 await process_frame
 var harbour_map: Node3D = harbour_world.get("scene")
 check(harbour_map.find_child("District_the_harbour",true,false) != null and harbour_map.find_child("CorporateFloorNavigation_4",true,false) != null, "Harbour alone builds the connected tower and accessible executive floor")
 check(not harbour_map.find_children("*","DestructibleGlass",true,false).is_empty(), "Harbour tower glazing has collision-backed breakable panes")
 check(int(harbour_map.get_meta("city_facade_bays",0)) >= 150, "Harbour's approach skyline retains detailed city facades as well as the playable glass tower")
 harbour_world.queue_free()
 await process_frame

 service.campaign_path = old_path
 service.active_mission = old_active
 service.progress.restore(old_progress)
 for path: String in [temp + "_campaign.json",temp + "_campaign.json.bak",temp + "_campaign.json.tmp",temp + "_legacy_station.json",temp + "_legacy_station.json.bak",temp + "_legacy_station.json.tmp",temp + "_station_checkpoint.json",temp + "_station_checkpoint.json.bak",temp + "_station_checkpoint.json.tmp",temp + "_streets_checkpoint.json",temp + "_streets_checkpoint.json.bak",temp + "_streets_checkpoint.json.tmp",temp + "_district_checkpoint.json",temp + "_district_checkpoint.json.bak",temp + "_district_checkpoint.json.tmp",temp + "_harbour_checkpoint.json",temp + "_harbour_checkpoint.json.bak",temp + "_harbour_checkpoint.json.tmp",temp + "_ngong_ping_checkpoint.json",temp + "_ngong_ping_checkpoint.json.bak",temp + "_ngong_ping_checkpoint.json.tmp"]:
  if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("HK RESULT: %d checks, %d failures" % [checks,failures])
 quit(0 if failures == 0 else 1)
