extends Control
var elapsed: float = 0.0
var debrief: VBoxContainer
var skip: Button

func _ready() -> void:
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 theme = BlacklineTheme.create()
 var bg := ColorRect.new()
 bg.color = Color(0.035, 0.055, 0.07)
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 debrief = VBoxContainer.new()
 debrief.position = Vector2(170, 150)
 debrief.custom_minimum_size.x = 940
 debrief.add_theme_constant_override("separation", 22)
 add_child(debrief)
 _label("BLACKLINE  /  OPERATION COMPLETE", 34)
 _label(str(Campaign.ending.get("name", "ASSIGNMENT")), 25)
 if str(Campaign.ending.get("id", "")) == "house":
  _label("FIVE PHYSICAL KEYS  /  VERIFIED\\nSEPARATE 70-DIGIT SAFE CODE  /  RECOVERED", 19)
 elif str(Campaign.ending.get("id", "")) in ["tung_chung", "hong_kong_sandbox", "the_streets", "the_district", "the_harbour", "ngong_ping"]:
  if Campaign.ending.get("id", "") == "hong_kong_sandbox":
   _label("ALL THREE MANDATORY TARGETS COMPLETE  /  KEYS 02, 03, 04 SECURED\nOPTIONAL INTEL %s" % ["SECURED" if Campaign.ending.get("intel_found", false) else "INCOMPLETE"], 19)
  else:
   _label("PRIMARY COMPLETE   /   PHYSICAL KEY SECURED\nOPTIONAL INTEL %s   /   WITNESS %s" % ["SECURED" if Campaign.ending.get("intel_found", false) else "NOT SECURED", "SPOKEN" if Campaign.ending.get("witness_found", false) else "NOT SPOKEN"], 19)
 else:
  _label("Records secured: %d" % Campaign.ending.get("records", 0), 20)
 _label("RUBY  /  DEBRIEF\n" + str(Campaign.ending.get("debrief", "")), 21)
 if str(Campaign.ending.get("id", "")) in ["tung_chung", "hong_kong_sandbox", "the_streets", "the_district", "the_harbour", "ngong_ping", "house"]:
  _label("USB KEYS  /  %d OF 5%s" % [Campaign.progress.recovered_keys.size(), ("  —  DECRYPTION INITIATED" if Campaign.progress.usb_decryption_seen else "  —  DECRYPTION READY") if Campaign.progress.usb_ready() else ""], 19)
 var unlock := str(Campaign.ending.get("unlock", ""))
 if not unlock.is_empty(): _label("LOADOUT UNLOCKED  /  " + Campaign.item_label(unlock), 20)
 skip = Button.new()
 skip.text = "CONTINUE TO MENU"
 skip.custom_minimum_size = Vector2(300, 50)
 skip.pressed.connect(_continue)
 debrief.add_child(skip)
 skip.grab_focus()
 debrief.modulate.a = 0.0

func _label(text: String, font_size: int) -> void:
 var label := Label.new()
 label.text = text
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_size_override("font_size", font_size)
 debrief.add_child(label)

func _process(delta: float) -> void:
 elapsed += delta
 debrief.modulate.a = minf(elapsed / 1.5, 1.0)

func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("release_mouse"):
  _continue()

func _continue() -> void:
 Campaign.active_mission = ""
 get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
