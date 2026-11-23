class_name CampaignProgress
extends RefCounted
## The ordered mission list is the single authority for unlocks and replay.
var missions: Array[Dictionary] = []
var equipment: Array[Dictionary] = []
# The existing Initiation records are the three assessment lesson milestones.
const LESSON_RECORDS := ["evaluation", "sensor_log", "dispatch"]
var completed_lessons: Array[String] = []
var equipped_coins: int = 0
var completed: Array[String] = []
var completed_targets: Dictionary = {}
var recovered_keys: Array[String] = []
var usb_decryption_seen: bool = false
var house_code_recovered: bool = false
var house_code: String = ""
var betrayal_seen: bool = false
var selected: String = "training_sidearm"
var last_mission: String = ""
var acquired_outfits: Array[String] = ["civilian"]
var equipped_outfit: String = "civilian"

func configure(data: Variant) -> bool:
 missions.clear()
 equipment.clear()
 if not data is Dictionary or not data.get("missions") is Array or not data.get("equipment") is Array: return false
 var seen: Array[String] = []
 for item: Variant in data["missions"]:
  if not item is Dictionary or not item.get("id") is String or item["id"].is_empty() or seen.has(item["id"]): return false
  if not item.get("scene") is String: return false
  seen.append(item["id"])
  missions.append(item.duplicate(true))
 for item: Variant in data["equipment"]:
  if not item is Dictionary or not item.get("id") is String or not item.get("missions") is Array: return false
  equipment.append(item.duplicate(true))
 return not missions.is_empty()

func mission(id: String) -> Dictionary:
 for entry: Dictionary in missions:
  if entry["id"] == id: return entry
 return {}

func is_unlocked(id: String) -> bool:
 var previous_required := ""
 for entry: Dictionary in missions:
  if entry["id"] == id:
   if str(entry["scene"]).is_empty(): return false
   if id == "house" and not usb_ready(): return false
   return previous_required.is_empty() or completed.has(previous_required)
  if not entry.get("optional", false): previous_required = str(entry["id"])
 return false

func next_mission() -> String:
 for entry: Dictionary in missions:
  if not entry.get("optional", false) and not completed.has(entry["id"]) and is_unlocked(entry["id"]): return entry["id"]
 return ""

func _mission_keys(entry: Dictionary) -> Array[String]:
 var result: Array[String] = []
 var raw: Variant = entry.get("key_ids", [])
 if raw is Array:
  for value: Variant in raw:
   if value is String and not value.is_empty() and not result.has(value): result.append(value)
 var single := str(entry.get("key_id", ""))
 if not single.is_empty() and not result.has(single): result.append(single)
 return result

func _target_ids(entry: Dictionary) -> Array[String]:
 var result: Array[String] = []
 var raw: Variant = entry.get("target_ids", [])
 if raw is Array:
  for value: Variant in raw:
   if value is String and not value.is_empty() and not result.has(value): result.append(value)
 return result

func record_target_completion(mission_id: String, target_id: String) -> bool:
 var entry := mission(mission_id)
 if not is_unlocked(mission_id) or target_id.is_empty() or not _target_ids(entry).has(target_id): return false
 var values: Array[String] = completed_targets.get(mission_id, [])
 if not values.has(target_id): values.append(target_id)
 completed_targets[mission_id] = values
 return true

func mark_complete(id: String) -> bool:
 if not is_unlocked(id): return false
 if id == "house" and not house_code_recovered: return false
 var entry := mission(id)
 for key_id: String in _mission_keys(entry):
  if not recovered_keys.has(key_id): return false
 var targets := _target_ids(entry)
 var recorded: Array = completed_targets.get(id, [])
 for target_id: String in targets:
  if not recorded.has(target_id): return false
 if not completed.has(id): completed.append(id)
 return true

func award_lesson(record_id: String) -> bool:
 if record_id not in LESSON_RECORDS: return false
 if not completed_lessons.has(record_id): completed_lessons.append(record_id)
 return true

func set_equipped_coins(amount: int) -> bool:
 if amount < 0 or amount > completed_lessons.size(): return false
 equipped_coins = amount
 return true

func item_unlocked(id: String) -> bool:
 for entry: Dictionary in equipment:
  if entry["id"] == id:
   var dependency := str(entry.get("unlock_after", ""))
   return dependency.is_empty() or completed.has(dependency)
 return false

func item_allowed(id: String, mission_id: String) -> bool:
 for entry: Dictionary in equipment:
  if entry["id"] == id: return item_unlocked(id) and mission_id in entry["missions"]
 return false

func select_item(id: String) -> bool:
 if not item_unlocked(id): return false
 selected = id
 return true

# Only a mission's own configured key can be added, never another mission's.
func secure_key(mission_id: String, key_id: String) -> bool:
 var entry := mission(mission_id)
 if not is_unlocked(mission_id) or key_id.is_empty() or not _mission_keys(entry).has(key_id): return false
 if not recovered_keys.has(key_id): recovered_keys.append(key_id)
 return true

func record_house_code(code: String) -> bool:
 if not is_unlocked("house") or code.length() != 70:
  return false
 for index: int in range(code.length()):
  var digit := code.unicode_at(index)
  if digit < 48 or digit > 57: return false
 house_code = code
 house_code_recovered = true
 return true

func acquire_outfit(id: String) -> bool:
 if not DisguiseSystem.has_outfit(id) or acquired_outfits.has(id): return false
 acquired_outfits.append(id)
 return true

func equip_outfit(id: String) -> bool:
 if not DisguiseSystem.has_outfit(id) or not acquired_outfits.has(id): return false
 equipped_outfit = id
 return true

func usb_ready() -> bool:
 var expected: Array[String] = []
 for entry: Dictionary in missions:
  for key_id: String in _mission_keys(entry):
   if not expected.has(key_id): expected.append(key_id)
 if expected.size() != 5: return false
 for key_id: String in expected:
  if not recovered_keys.has(key_id): return false
 return true

func restore(data: Dictionary) -> void:
 completed.clear()
 completed_targets.clear()
 recovered_keys.clear()
 completed_lessons.clear()
 house_code_recovered = false
 house_code = ""
 betrayal_seen = false
 var schema_version := int(data.get("schema_version", 1))
 acquired_outfits.assign(["civilian"])
 equipped_outfit = "civilian"
 equipped_coins = 0
 usb_decryption_seen = false
 var raw_keys: Variant = data.get("recovered_keys", [])
 var raw: Variant = data.get("completed", [])
 if not raw_keys is Array: raw_keys = []
 if not raw is Array: raw = []
 # Physical key IDs are explicit save facts, so preserve known IDs even when
 # an old completion flag no longer meets the updated objective contract. Keys
 # do not complete missions; older campaign completions for target operations
 # are ignored because their saves cannot prove the newly required target tags.
 var valid_keys: Array[String] = []
 for entry: Dictionary in missions:
  for key_id: String in _mission_keys(entry):
   if not valid_keys.has(key_id): valid_keys.append(key_id)
 for key_variant: Variant in raw_keys:
  if key_variant is String and valid_keys.has(key_variant) and not recovered_keys.has(key_variant):
   recovered_keys.append(key_variant)
 var raw_targets: Variant = data.get("completed_targets", {})
 if schema_version >= 2 and raw_targets is Dictionary:
  for entry: Dictionary in missions:
   var mission_id := str(entry["id"])
   var stored_targets: Variant = raw_targets.get(mission_id, [])
   if not stored_targets is Array: continue
   var accepted: Array[String] = []
   for target_id: String in _target_ids(entry):
    if target_id in stored_targets: accepted.append(target_id)
   if not accepted.is_empty(): completed_targets[mission_id] = accepted
 for entry: Dictionary in missions:
  var id := str(entry["id"])
  if not is_unlocked(id): continue
  var all_keys_found := true
  for key_id: String in _mission_keys(entry):
   if not recovered_keys.has(key_id): all_keys_found = false
  var legacy_safe_completion := id == "initiation"
  if id in raw and all_keys_found and legacy_safe_completion:
   completed.append(id)
  elif id in raw and schema_version >= 2 and all_keys_found:
   mark_complete(id)
 # Completed legacy Initiation necessarily required all three records.
 # For new or partial saves, only explicitly recognized lesson IDs count.
 var raw_lessons: Variant = data.get("completed_lessons", [])
 if raw_lessons is Array:
  for lesson: String in LESSON_RECORDS:
   if lesson in raw_lessons: completed_lessons.append(lesson)
 if completed.has("initiation"):
  for lesson: String in LESSON_RECORDS:
   if not completed_lessons.has(lesson): completed_lessons.append(lesson)
 var raw_coins: Variant = data.get("equipped_coins", 0)
 if (raw_coins is int or raw_coins is float) and is_finite(float(raw_coins)):
  equipped_coins = clampi(int(raw_coins), 0, completed_lessons.size())
 var restored_house_code: Variant = data.get("house_code", "")
 if schema_version >= 2 and data.get("house_code_recovered", false) == true and restored_house_code is String and restored_house_code.length() == 70 and is_unlocked("house"):
  var digits_only := true
  for index: int in range(restored_house_code.length()):
   var digit := restored_house_code.unicode_at(index)
   if digit < 48 or digit > 57: digits_only = false
  if digits_only:
   house_code = restored_house_code
   house_code_recovered = true
 if "house" in raw and not completed.has("house") and house_code_recovered and is_unlocked("house"):
  mark_complete("house")
 usb_decryption_seen = data.get("usb_decryption_seen", false) == true and usb_ready() and completed.has("ngong_ping") and completed.has("house") and house_code_recovered
 betrayal_seen = schema_version >= 2 and data.get("betrayal_seen", false) == true and usb_decryption_seen
 var desired: Variant = data.get("selected", "training_sidearm")
 selected = "training_sidearm"
 if desired is String: select_item(desired)
 var last: Variant = data.get("last_mission", "")
 last_mission = last if last is String and is_unlocked(last) else ""
 var raw_outfits: Variant = data.get("acquired_outfits", [])
 if raw_outfits is Array:
  for outfit_variant: Variant in raw_outfits:
   var outfit_id := str(outfit_variant)
   if DisguiseSystem.has_outfit(outfit_id) and not acquired_outfits.has(outfit_id): acquired_outfits.append(outfit_id)
 var desired_outfit: Variant = data.get("equipped_outfit", "civilian")
 if desired_outfit is String: equip_outfit(desired_outfit)

func snapshot() -> Dictionary:
 return {"schema_version": 2, "completed_lessons": completed_lessons.duplicate(), "equipped_coins": equipped_coins, "completed": completed.duplicate(), "completed_targets": completed_targets.duplicate(true), "recovered_keys": recovered_keys.duplicate(), "usb_decryption_seen": usb_decryption_seen, "house_code_recovered": house_code_recovered, "house_code": house_code, "betrayal_seen": betrayal_seen, "selected": selected, "last_mission": last_mission, "acquired_outfits": acquired_outfits.duplicate(), "equipped_outfit": equipped_outfit}
