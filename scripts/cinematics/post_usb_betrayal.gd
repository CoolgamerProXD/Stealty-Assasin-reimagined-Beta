extends Node3D
## Non-graphic, interactive aftermath: the player must intervene to protect Ruby.
var elapsed := 0.0
var waiting_for_rescue := false
var rescued := false
var finished := false
var camera: Camera3D
var player_actor: StylizedPerson
var ruby_actor: StylizedPerson
var manager_actor: StylizedPerson
var subtitles: Label
var prompt: Label
var continue_button: Button
var effect: AudioStreamPlayer

func _ready() -> void:
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 if not Campaign.progress.usb_decryption_seen or not Campaign.progress.completed.has("house"):
  # This guard can run while the scene is still being attached by SceneTree.
  # Defer the redirect to avoid removing the current scene during _ready().
  get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
  return
 var world := WorldEnvironment.new()
 var environment := Environment.new()
 environment.background_mode = Environment.BG_COLOR
 environment.background_color = Color(0.10,0.14,0.16)
 environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 environment.ambient_light_color = Color(0.75,0.80,0.78)
 environment.ambient_light_energy = 0.8
 world.environment = environment
 add_child(world)
 _box(Vector3(0,-0.18,0),Vector3(20,0.36,22),Color(0.31,0.34,0.32))
 _box(Vector3(0,3.4,-7),Vector3(20,6.8,0.3),Color(0.48,0.48,0.42))
 _box(Vector3(-10,3.4,0),Vector3(0.3,6.8,14),Color(0.44,0.47,0.45))
 _box(Vector3(10,3.4,0),Vector3(0.3,6.8,14),Color(0.44,0.47,0.45))
 _box(Vector3(0,1.5,-4.0),Vector3(7.0,1.0,1.5),Color(0.25,0.20,0.16))
 _box(Vector3(-6,1.4,2.0),Vector3(0.18,2.8,4.0),Color(0.22,0.29,0.31))
 _box(Vector3(6,1.4,2.0),Vector3(0.18,2.8,4.0),Color(0.22,0.29,0.31))
 _box(Vector3(0,5.5,0),Vector3(20,0.25,14),Color(0.21,0.25,0.25))
 for pos: Vector3 in [Vector3(-5,5.1,-3),Vector3(4,5.1,0),Vector3(0,5.1,4)]:
  var light := OmniLight3D.new()
  light.position = pos
  light.light_color = Color(1.0,0.79,0.55)
  light.light_energy = 0.65
  light.omni_range = 9.0
  add_child(light)
 player_actor = StylizedPerson.new()
 player_actor.role = "visitor"
 player_actor.position = Vector3(0,0,5)
 add_child(player_actor)
 ruby_actor = StylizedPerson.new()
 ruby_actor.role = "ruby"
 ruby_actor.position = Vector3(-1.2,0,-3.2)
 add_child(ruby_actor)
 manager_actor = StylizedPerson.new()
 manager_actor.role = "manager"
 manager_actor.position = Vector3(1.3,0,-3.0)
 add_child(manager_actor)
 camera = Camera3D.new()
 Campaign.configure_camera(camera)
 camera.position = Vector3(-4,3.0,5.5)
 add_child(camera)
 camera.look_at(Vector3(0,1.25,-2.7),Vector3.UP)
 camera.make_current()
 effect = AudioStreamPlayer.new()
 effect.bus = "SFX"
 effect.stream = ProceduralSound.tone(92.0,0.22,0.10)
 add_child(effect)
 var canvas := CanvasLayer.new()
 add_child(canvas)
 var panel := PanelContainer.new()
 panel.position = Vector2(120,530)
 panel.size = Vector2(1040,160)
 canvas.add_child(panel)
 var stack := VBoxContainer.new()
 stack.add_theme_constant_override("separation",8)
 panel.add_child(stack)
 subtitles = Label.new()
 subtitles.custom_minimum_size = Vector2(1000,82)
 subtitles.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 subtitles.add_theme_font_size_override("font_size",22)
 stack.add_child(subtitles)
 prompt = Label.new()
 prompt.add_theme_font_size_override("font_size",19)
 prompt.add_theme_color_override("font_color",Color(1.0,0.78,0.45))
 stack.add_child(prompt)
 continue_button = Button.new()
 continue_button.text = "CONTINUE  /  BEGIN THE QUIET HUNT"
 continue_button.custom_minimum_size = Vector2(350,42)
 continue_button.visible = false
 continue_button.pressed.connect(_finish)
 stack.add_child(continue_button)
 _box(Vector3(0,0.01,-7.0),Vector3(12,0.02,0.2),Color(0.72,0.58,0.36))
 subtitles.text = "BLACKLINE SECURE ROOM  /  DECRYPTION COMPLETE"
 prompt.text = ""

func _box(pos: Vector3, size: Vector3, color: Color) -> void:
 var mesh := BoxMesh.new()
 mesh.size = size
 var visual := MeshInstance3D.new()
 visual.mesh = mesh
 visual.position = pos
 var material := StandardMaterial3D.new()
 material.albedo_color = color
 material.roughness = 0.82
 visual.material_override = material
 add_child(visual)

func _process(delta: float) -> void:
 if finished or waiting_for_rescue: return
 elapsed += delta
 player_actor.animate_motion(delta,0.0)
 ruby_actor.animate_motion(delta,0.0)
 manager_actor.animate_motion(delta,0.0)
 if elapsed < 4.5:
  subtitles.text = "RUBY: Five physical keys and the separate safe code opened the drive. Its contents remain under analysis."
 elif elapsed < 8.5:
  subtitles.text = "SENIOR BLACKLINE MANAGER: Give the decrypted material to me. No one else needs to see it."
 elif elapsed < 12.0:
  subtitles.text = "The agent listens from the adjoining room. The senior manager moves toward Ruby."
 else:
  waiting_for_rescue = true
  manager_actor.position = Vector3(-0.4,0,-1.5)
  manager_actor.rotation.y = PI
  ruby_actor.rotation.y = 0.0
  subtitles.text = "The manager turns on Ruby and makes a lethal move. Pull her behind cover now; the attempt is staged non-graphically."
  prompt.text = "PRESS E  /  PULL RUBY TO COVER"

func _unhandled_input(event: InputEvent) -> void:
 if not waiting_for_rescue or rescued: return
 if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
  _rescue_ruby()
  get_viewport().set_input_as_handled()

func _rescue_ruby() -> void:
 if rescued: return
 rescued = true
 waiting_for_rescue = false
 player_actor.position = Vector3(-0.7,0,0.4)
 ruby_actor.position = Vector3(-2.1,0,1.1)
 manager_actor.position = Vector3(2.0,0,-2.2)
 manager_actor.rotation.z = 0.75
 effect.play()
 if not Campaign.progress.betrayal_seen and not Campaign.mark_betrayal_seen():
  subtitles.text = "Ruby is safe, but the betrayal record could not be saved. Try again after checking campaign storage."
  prompt.text = ""
  return
 subtitles.text = "RUBY: He was working for the Covenant. They have ten heads; Constance is the only one we can name. The senior manager is alive, and we keep this between us."
 prompt.text = "ONLY RUBY AND THE AGENT KNOW  /  NO ONE ELSE IS TOLD"
 await get_tree().create_timer(4.0).timeout
 if not is_inside_tree(): return
 subtitles.text = "RUBY: We hunt the Covenant quietly from now on. The USB contents, client, deal and Prometheus research purpose remain unresolved."
 prompt.text = ""
 continue_button.visible = true
 continue_button.grab_focus()

func _finish() -> void:
 if not rescued or finished: return
 finished = true
 Campaign.active_mission = ""
 get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
