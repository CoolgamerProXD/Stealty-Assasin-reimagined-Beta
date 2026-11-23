extends Node
## Campaign data is deliberately separate from each mission's existing save file.
const CAMPAIGN_PATH := "user://blackline_campaign.json"
const SETTINGS_PATH := "user://blackline_settings.json"
var campaign_path: String = CAMPAIGN_PATH
var settings_path: String = SETTINGS_PATH
var progress: CampaignProgress = CampaignProgress.new()
var active_mission: String = ""
var load_checkpoint: bool = false
var return_to_maps: bool = false
var ending: Dictionary = {}
var settings: Dictionary = {"resolution": "1280x720", "fullscreen": false, "sensitivity": 0.0025, "volume": 0.8, "music_volume": 1.0, "sfx_volume": 1.0, "ambient_volume": 1.0, "dialogue_volume": 1.0, "graphics": "MEDIUM", "show_fps": false, "shadows": true, "practicals": true, "long_view": true}

func _ready() -> void:
 var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://resources/campaign.json"))
 if not progress.configure(data):
  push_error("Invalid campaign data")
  return
 progress.restore(SaveStore.read(campaign_path))
 _load_settings()

func persist() -> bool:
 return SaveStore.write(campaign_path, progress.snapshot())

func checkpoint_path(id: String) -> String:
 if id == "meridian": return "user://meridian_save.json" # Preserve existing saves.
 if id == "initiation": return "user://initiation_save.json"
 if id in ["tung_chung", "the_streets", "the_district", "the_harbour", "ngong_ping", "house", "hong_kong_sandbox"]:
  return "user://blackline_" + id + "_save.json"
 return ""

func has_checkpoint(id: String) -> bool:
 var path := checkpoint_path(id)
 return not path.is_empty() and not SaveStore.read(path).is_empty()

func begin(id: String, resume: bool = false) -> bool:
 if not progress.is_unlocked(id): return false
 var entry := progress.mission(id)
 if entry.is_empty() or not ResourceLoader.exists(str(entry["scene"])): return false
 if resume and not has_checkpoint(id): return false
 var old_last := progress.last_mission
 progress.last_mission = id
 if not persist():
  progress.last_mission = old_last
  return false
 active_mission = id
 load_checkpoint = resume
 get_tree().change_scene_to_file(str(entry["scene"]))
 return true

func award_initiation_lesson(record_id: String) -> bool:
 if active_mission != "initiation": return false
 var previous := progress.completed_lessons.duplicate()
 if not progress.award_lesson(record_id): return false
 if not persist():
  progress.completed_lessons.assign(previous)
  return false
 return true

func acquire_outfit(id: String) -> bool:
 var previous := progress.acquired_outfits.duplicate()
 if not progress.acquire_outfit(id): return false
 if not persist():
  progress.acquired_outfits.assign(previous)
  return false
 return true

func equip_outfit(id: String) -> bool:
 var previous := progress.equipped_outfit
 if not progress.equip_outfit(id): return false
 if not persist():
  progress.equipped_outfit = previous
  return false
 return true

func record_mission_target(id: String, target_id: String) -> bool:
 if active_mission != id: return false
 var previous: Dictionary = progress.completed_targets.duplicate(true)
 if not progress.record_target_completion(id, target_id): return false
 if not persist():
  progress.completed_targets = previous
  return false
 return true

func secure_mission_key(id: String, key_id: String) -> bool:
 if active_mission != id: return false
 var previous := progress.recovered_keys.duplicate()
 if not progress.secure_key(id, key_id): return false
 if not persist():
  progress.recovered_keys.assign(previous)
  return false
 return true

func record_house_code(code: String) -> bool:
 if active_mission != "house" or not progress.usb_ready() or not progress.is_unlocked("house"): return false
 var previous_code := progress.house_code
 var previous_recovered := progress.house_code_recovered
 if not progress.record_house_code(code): return false
 if not persist():
  progress.house_code = previous_code
  progress.house_code_recovered = previous_recovered
  return false
 return true

func mark_betrayal_seen() -> bool:
 if not progress.usb_decryption_seen or not progress.completed.has("house") or progress.betrayal_seen: return false
 progress.betrayal_seen = true
 if not persist():
  progress.betrayal_seen = false
  return false
 return true

func acknowledge_usb_decryption() -> bool:
 if not progress.usb_ready() or not progress.completed.has("ngong_ping") or not progress.completed.has("house") or not progress.house_code_recovered: return false
 var previous := progress.usb_decryption_seen
 progress.usb_decryption_seen = true
 if not persist():
  progress.usb_decryption_seen = previous
  return false
 return true

func complete(id: String, count: int) -> bool:
 if id != active_mission: return false
 var already := progress.completed.has(id)
 if not progress.mark_complete(id): return false
 if not persist():
  if not already: progress.completed.erase(id)
  return false
 var entry := progress.mission(id)
 ending = {"id": id, "name": entry.get("name", id), "records": count, "debrief": entry.get("debrief", ""), "unlock": entry.get("unlock", "") if not already else ""}
 return true

func item_label(id: String) -> String:
 for entry: Dictionary in progress.equipment:
  if entry["id"] == id: return str(entry.get("name", id))
 return id

func _load_settings() -> void:
 var data := SaveStore.read(settings_path)
 var resolution: Variant = data.get("resolution", "1280x720")
 if resolution is String and resolution in ["1280x720", "1600x900"]: settings["resolution"] = resolution
 var fullscreen: Variant = data.get("fullscreen", false)
 if fullscreen is bool: settings["fullscreen"] = fullscreen
 var sensitivity: Variant = data.get("sensitivity", 0.0025)
 if (sensitivity is int or sensitivity is float) and is_finite(float(sensitivity)): settings["sensitivity"] = clampf(float(sensitivity), 0.001, 0.006)
 var volume: Variant = data.get("volume", 0.8)
 if (volume is int or volume is float) and is_finite(float(volume)): settings["volume"] = clampf(float(volume), 0.0, 1.0)
 for option: String in ["music_volume", "sfx_volume", "ambient_volume", "dialogue_volume"]:
  var level: Variant = data.get(option, 1.0)
  settings[option] = clampf(float(level), 0.0, 1.0) if (level is int or level is float) and is_finite(float(level)) else 1.0
 var graphics: Variant = data.get("graphics", "MEDIUM")
 if graphics is String and graphics in ["LOW", "MEDIUM", "HIGH"]: settings["graphics"] = graphics
 for option: String in ["shadows", "practicals", "long_view"]:
  var value: Variant = data.get(option, true)
  if value is bool: settings[option] = value
 var show_fps: Variant = data.get("show_fps", false)
 if show_fps is bool: settings["show_fps"] = show_fps
 apply_settings()

func configure_camera(camera: Camera3D) -> void:
 camera.add_to_group("quality_cameras")
 camera.far = 220.0 if bool(settings["long_view"]) else 75.0

func apply_settings() -> void:
 var viewport := get_viewport()
 var quality: String = settings["graphics"]
 viewport.scaling_3d_scale = 0.7 if quality == "LOW" else (0.85 if quality == "MEDIUM" else 1.0)
 # Multisampling is disproportionately expensive on software/integrated GPUs.
 # HIGH uses one post-process AA pass instead, alongside full resolution.
 viewport.msaa_3d = Viewport.MSAA_DISABLED
 viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if quality == "HIGH" else Viewport.SCREEN_SPACE_AA_DISABLED
 viewport.positional_shadow_atlas_size = 2048 if quality == "HIGH" else (1024 if quality == "MEDIUM" else 0)
 for camera: Node in get_tree().get_nodes_in_group("quality_cameras"):
  (camera as Camera3D).far = 220.0 if bool(settings["long_view"]) else 75.0
 for light: Node in get_tree().get_nodes_in_group("quality_lights"):
  (light as Light3D).shadow_enabled = quality != "LOW" and bool(settings["shadows"])
 for light: Node in get_tree().get_nodes_in_group("quality_practicals"):
  (light as Light3D).visible = quality != "LOW" and bool(settings["practicals"])
 for detail: Node in get_tree().get_nodes_in_group("quality_detail"):
  (detail as Node3D).visible = quality == "HIGH"
 for probe: Node in get_tree().get_nodes_in_group("quality_reflections"):
  (probe as ReflectionProbe).visible = quality == "HIGH"
 # Ensure buses exist even with legacy installs that have no bus layout.
 for item: Array in [["Master", "volume"], ["Music", "music_volume"], ["SFX", "sfx_volume"], ["Ambient", "ambient_volume"], ["Dialogue", "dialogue_volume"]]:
  var bus_name: String = item[0]
  var bus := AudioServer.get_bus_index(bus_name)
  if bus < 0:
   AudioServer.add_bus()
   bus = AudioServer.bus_count - 1
   AudioServer.set_bus_name(bus, bus_name)
  if bus_name != "Master": AudioServer.set_bus_send(bus, "Master")
  var level := clampf(float(settings.get(item[1], 1.0)), 0.0, 1.0)
  AudioServer.set_bus_mute(bus, level <= 0.0)
  AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(0.001, level)))
 if DisplayServer.get_name() != "headless":
  DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)
  var size := Vector2i(1600, 900) if settings["resolution"] == "1600x900" else Vector2i(1280, 720)
  if not settings["fullscreen"]: DisplayServer.window_set_size(size)

func save_settings() -> bool:
 apply_settings()
 return SaveStore.write(settings_path, settings)
