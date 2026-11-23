extends Control
var panel: VBoxContainer
var notice: String = ""
var ui_audio: AudioStreamPlayer

func _ready() -> void:
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 theme = BlacklineTheme.create()
 ui_audio = AudioStreamPlayer.new()
 ui_audio.bus = "SFX"
 ui_audio.stream = ProceduralSound.tone(520.0, 0.06, 0.025)
 add_child(ui_audio)
 _build_shell()
 if not Campaign.pending_briefing.is_empty():
  var pending := Campaign.pending_briefing
  Campaign.pending_briefing = ""
  _briefing(pending)
 elif Campaign.return_to_maps:
  Campaign.return_to_maps = false
  _missions()
 else:
  _home()

func _build_shell() -> void:
 var backdrop := preload("res://scripts/ui/menu_backdrop.gd").new()
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(backdrop)
 var stripe := ColorRect.new()
 stripe.color = Color(0.65, 0.43, 0.23)
 stripe.position = Vector2(80, 86)
 stripe.size = Vector2(4, 500)
 add_child(stripe)
 var title := Label.new()
 title.text = "PROJECT\nASSASSIN"
 title.position = Vector2(112, 74)
 title.add_theme_font_size_override("font_size", 47)
 add_child(title)
 var subtitle := Label.new()
 subtitle.text = "BLACKLINE   /   FIELD OPERATIONS"
 subtitle.position = Vector2(115, 210)
 subtitle.add_theme_font_size_override("font_size", 16)
 subtitle.modulate = Color(0.78, 0.67, 0.52)
 add_child(subtitle)
 var footer := Label.new()
 footer.text = "OPERATIONS DIVISION     /     SECURE CHANNEL"
 footer.position = Vector2(112, 635)
 footer.add_theme_font_size_override("font_size", 13)
 footer.modulate = Color(0.55, 0.65, 0.64)
 add_child(footer)
 panel = VBoxContainer.new()
 panel.position = Vector2(575, 110)
 panel.custom_minimum_size = Vector2(590, 0)
 panel.add_theme_constant_override("separation", 10)
 add_child(panel)

func _clear() -> void:
 panel.position.y = 110
 panel.add_theme_constant_override("separation", 10)
 for child: Node in panel.get_children():
  panel.remove_child(child)
  child.queue_free()

func _text(value: String, size: int = 19) -> Label:
 var label := Label.new()
 label.text = value
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 label.custom_minimum_size.x = 560
 label.add_theme_font_size_override("font_size", size)
 panel.add_child(label)
 return label

func _button(title: String, callback: Callable, disabled: bool = false) -> Button:
 var button := Button.new()
 button.text = title
 button.disabled = disabled
 button.custom_minimum_size = Vector2(500, 44)
 button.pressed.connect(ui_audio.play)
 button.pressed.connect(callback)
 panel.add_child(button)
 return button

func _home() -> void:
 _clear()
 _text("OPERATIONS", 30)
 _text("The Covenant moves in the margins. Blackline follows the evidence.", 17)
 if not notice.is_empty(): _text(notice, 17)
 var next := Campaign.progress.next_mission()
 var campaign_button := _button("CAMPAIGN  /  NEXT ASSIGNMENT", func() -> void: _briefing(next), next.is_empty())
 var last := Campaign.progress.last_mission
 _button("CONTINUE  /  LOAD CHECKPOINT", func() -> void: _start(last, true), last.is_empty() or not Campaign.has_checkpoint(last))
 _button("MISSION SELECTION", _missions)
 _button("LOADOUT", _loadout)
 _button("SETTINGS", _settings)
 _button("EXIT GAME", func() -> void: get_tree().quit())
 if not campaign_button.disabled: campaign_button.grab_focus()

func _missions() -> void:
 _clear()
 panel.add_theme_constant_override("separation", 3)
 _text("MISSION SELECTION", 30)
 _text("Assignments  /  USB keys: %d / 5" % Campaign.progress.recovered_keys.size(), 15)
 for entry: Dictionary in Campaign.progress.missions:
  var id := str(entry["id"])
  var unlocked: bool = Campaign.progress.is_unlocked(id)
  var status := "COMPLETED / REPLAY" if Campaign.progress.completed.has(id) else ("AVAILABLE" if unlocked else "LOCKED")
  _button("%s   —   %s" % [entry.get("name", id), status], func() -> void: _briefing(id), not unlocked)
 _button("EXPLORATION PREVIEWS", _previews)
 _button("BACK", _home).grab_focus()

func _previews() -> void:
 _clear()
 panel.add_theme_constant_override("separation", 3)
 _text("EXPLORATION PREVIEWS", 30)
 _text("Independent map studies; no campaign progress", 15)
 for entry: Array in [["TUNG CHUNG", "res://scenes/tung_chung_preview.tscn"], ["HONG KONG", "res://scenes/hong_kong_preview.tscn"], ["NGONG PING", "res://scenes/ngong_ping_preview.tscn"]]:
  var path := str(entry[1])
  _button(str(entry[0]) + "  —  EXPLORE PREVIEW", func() -> void: get_tree().change_scene_to_file(path))
 _button("BACK", _missions).grab_focus()

func _briefing(id: String) -> void:
 _clear()
 var entry: Dictionary = Campaign.progress.mission(id)
 if entry.is_empty() or not Campaign.progress.is_unlocked(id):
  notice = "That assignment is locked."
  _home()
  return
 _text(str(entry.get("name", id)), 30)
 _text("RUBY  /  BRIEFING", 16)
 _text("AGENT  /  " + Campaign.display_agent_name(), 15)
 _text(str(entry.get("briefing", "")), 20)
 var item: String = Campaign.progress.selected
 var allowed: bool = Campaign.progress.item_allowed(item, id)
 _text("Loadout: %s%s" % [Campaign.item_label(item), "" if allowed else " (not permitted for this assignment)"], 17)
 _button("BEGIN ASSIGNMENT", func() -> void: _start(id, false)).grab_focus()
 _button("BACK", _home)

func _start(id: String, resume: bool) -> void:
 if not Campaign.begin(id, resume):
  notice = "Unable to start. Check the mission or save file."
  _home()

func _loadout() -> void:
 _clear()
 panel.add_theme_constant_override("separation", 5)
 _text("LOADOUT", 30)
 _text(notice if not notice.is_empty() else "Training sidearm is standard; select your optional item.", 16)
 for entry: Dictionary in Campaign.progress.equipment:
  var id := str(entry["id"])
  var unlocked: bool = Campaign.progress.item_unlocked(id)
  var tag := "SELECTED" if Campaign.progress.selected == id else ("AVAILABLE" if unlocked else "LOCKED")
  var item_button := _button("%s  /  %s" % [entry.get("name", id), tag], func() -> void: _select_item(id), not unlocked)
  item_button.tooltip_text = str(entry.get("description", ""))
 var lessons: Array[String] = Campaign.progress.completed_lessons
 var labels: Array[String] = []
 for i: int in range(3):
  labels.append("%s %s" % [["1 OBSERVE", "2 AWARENESS", "3 EVIDENCE"][i], "✓" if lessons.has(CampaignProgress.LESSON_RECORDS[i]) else "—"])
 _text("COINS  /  EARNED %d   ·   EQUIPPED %d   ·   AVAILABLE %d\n%s" % [lessons.size(), Campaign.progress.equipped_coins, lessons.size() - Campaign.progress.equipped_coins, "    ".join(labels)], 16)
 _text("G tosses a coin in later missions; stock resets each deployment.", 15)
 _button("COINS: %d   /   CHANGE (0–%d)" % [Campaign.progress.equipped_coins, lessons.size()], _cycle_coins, lessons.is_empty())
 _button("BACK", _home).grab_focus()

func _cycle_coins() -> void:
 var previous: int = Campaign.progress.equipped_coins
 Campaign.progress.set_equipped_coins((previous + 1) % (Campaign.progress.completed_lessons.size() + 1))
 if not Campaign.persist():
  Campaign.progress.set_equipped_coins(previous)
  notice = "Could not save coin loadout."
 else: notice = ""
 _loadout()

func _select_item(id: String) -> void:
 var previous: String = Campaign.progress.selected
 if Campaign.progress.select_item(id) and not Campaign.persist():
  Campaign.progress.selected = previous
  notice = "Could not save loadout."
 else: notice = ""
 _loadout()

func _settings() -> void:
 _clear()
 panel.position.y = 40
 var settings := SettingsPanel.new()
 panel.add_child(settings)
 settings.back_requested.connect(_home)
