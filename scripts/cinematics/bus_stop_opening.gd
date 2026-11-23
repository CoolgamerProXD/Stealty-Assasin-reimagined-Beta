extends Node3D
## Interactive, non-graphic opener. It records only the player-selected callsign;
## it does not complete a mission, award a target, or grant a USB key.
var phase := "name"
var elapsed := 0.0
var chosen_name := ""
var player_actor: StylizedPerson
var robber_actor: StylizedPerson
var ruby_actor: StylizedPerson
var subtitles: Label
var prompt: Label
var callsign_input: LineEdit
var name_button: Button
var continue_button: Button

func _ready() -> void:
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 _build_environment()
 _build_actors()
 _build_interface()

func _build_environment() -> void:
 var world := WorldEnvironment.new()
 var environment := Environment.new()
 environment.background_mode = Environment.BG_COLOR
 environment.background_color = Color(0.11, 0.16, 0.19)
 environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 environment.ambient_light_color = Color(0.72, 0.79, 0.82)
 environment.ambient_light_energy = 0.8
 world.environment = environment
 add_child(world)
 _box(Vector3(0, -0.18, 0), Vector3(24, 0.36, 26), Color(0.22, 0.27, 0.29))
 _box(Vector3(0, 0.015, 0), Vector3(24, 0.025, 5.5), Color(0.12, 0.15, 0.17))
 _box(Vector3(0, 0.04, 3.0), Vector3(24, 0.08, 0.25), Color(0.72, 0.63, 0.46))
 # A fictional shelter and bus-stop marker establish the location without copying real signage.
 for x: float in [-4.0, 4.0]:
  _box(Vector3(x, 1.55, -2.8), Vector3(0.16, 3.1, 0.16), Color(0.22, 0.32, 0.35))
 _box(Vector3(0, 3.05, -2.8), Vector3(8.2, 0.18, 3.0), Color(0.16, 0.24, 0.27))
 _box(Vector3(0, 1.55, -4.25), Vector3(8.0, 2.8, 0.08), Color(0.30, 0.43, 0.45))
 _box(Vector3(5.1, 1.8, 0.0), Vector3(0.12, 3.6, 0.12), Color(0.20, 0.25, 0.27))
 _box(Vector3(5.1, 3.6, 0.0), Vector3(0.7, 0.1, 0.7), Color(0.82, 0.67, 0.38))
 _box(Vector3(-2.2, 0.52, -3.55), Vector3(2.3, 0.16, 0.48), Color(0.24, 0.29, 0.28))
 for x: float in [-3.1, -1.3]:
  _box(Vector3(x, 0.28, -3.55), Vector3(0.12, 0.45, 0.16), Color(0.18, 0.22, 0.23))
 var light := OmniLight3D.new()
 light.position = Vector3(0, 4.8, 1)
 light.light_color = Color(0.95, 0.78, 0.55)
 light.light_energy = 1.0
 light.omni_range = 14.0
 add_child(light)
 var camera := Camera3D.new()
 Campaign.configure_camera(camera)
 camera.position = Vector3(0, 3.0, 9.5)
 add_child(camera)
 camera.look_at(Vector3(0, 1.15, -0.7), Vector3.UP)
 camera.make_current()

func _build_actors() -> void:
 player_actor = StylizedPerson.new()
 player_actor.role = "visitor"
 player_actor.appearance_seed = 41
 player_actor.position = Vector3(0, 0, 2.0)
 add_child(player_actor)
 robber_actor = StylizedPerson.new()
 robber_actor.role = "security"
 robber_actor.appearance_seed = 87
 robber_actor.position = Vector3(0.35, 0, -1.0)
 robber_actor.rotation.y = PI
 add_child(robber_actor)
 ruby_actor = StylizedPerson.new()
 ruby_actor.role = "ruby"
 ruby_actor.appearance_seed = 12
 ruby_actor.position = Vector3(-5.5, 0, -2.2)
 ruby_actor.rotation.y = -0.3
 add_child(ruby_actor)

func _build_interface() -> void:
 var canvas := CanvasLayer.new()
 canvas.layer = 10
 add_child(canvas)
 var panel := PanelContainer.new()
 panel.position = Vector2(100, 485)
 panel.size = Vector2(1080, 205)
 canvas.add_child(panel)
 var stack := VBoxContainer.new()
 stack.add_theme_constant_override("separation", 6)
 panel.add_child(stack)
 var heading := Label.new()
 heading.text = "BLACKLINE  /  FIRST CONTACT"
 heading.add_theme_font_size_override("font_size", 18)
 stack.add_child(heading)
 subtitles = Label.new()
 subtitles.custom_minimum_size = Vector2(1020, 56)
 subtitles.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 subtitles.add_theme_font_size_override("font_size", 20)
 stack.add_child(subtitles)
 prompt = Label.new()
 prompt.add_theme_color_override("font_color", Color(1.0, 0.78, 0.45))
 prompt.add_theme_font_size_override("font_size", 16)
 stack.add_child(prompt)
 callsign_input = LineEdit.new()
 callsign_input.placeholder_text = "Choose your agent callsign (1–24 characters)"
 callsign_input.max_length = 24
 callsign_input.text = Campaign.progress.agent_name
 callsign_input.custom_minimum_size.x = 550
 callsign_input.text_submitted.connect(_confirm_name)
 stack.add_child(callsign_input)
 name_button = Button.new()
 name_button.text = "CONFIRM CALLSIGN  /  CONTINUE"
 name_button.pressed.connect(_confirm_name.bind(""))
 stack.add_child(name_button)
 continue_button = Button.new()
 continue_button.text = "REPORT TO INITIATION"
 continue_button.visible = false
 continue_button.pressed.connect(_finish_opening)
 stack.add_child(continue_button)
 subtitles.text = "Ruby is pursuing a hooded thief who stole a sealed USB. Its contents are unknown. Choose the callsign BLACKLINE will use for you."
 prompt.text = "Your callsign is saved with campaign progress; you can edit it until this opening is completed."
 callsign_input.grab_focus()

func _confirm_name(submitted: String = "") -> void:
 if phase != "name": return
 var value := submitted if not submitted.is_empty() else callsign_input.text
 if not Campaign.set_agent_name(value):
  prompt.text = "Enter a callsign of 1–24 visible characters."
  callsign_input.grab_focus()
  return
 chosen_name = Campaign.progress.agent_name
 callsign_input.visible = false
 name_button.visible = false
 phase = "chase"
 elapsed = 0.0
 subtitles.text = "Ruby cuts through the bus-stop shelter after the thief. The USB stays sealed; nobody here knows what is on it."
 prompt.text = "Watch for an opening."

func _process(delta: float) -> void:
 if phase == "chase":
  elapsed += delta
  ruby_actor.position.x = lerpf(-5.5, -1.4, clampf(elapsed / 2.2, 0.0, 1.0))
  ruby_actor.position.z = lerpf(-2.2, -1.8, clampf(elapsed / 2.2, 0.0, 1.0))
  ruby_actor.animate_motion(delta, 1.6)
  if elapsed >= 2.2:
   phase = "trip"
   subtitles.text = "You cut across the thief’s path."
   prompt.text = "PRESS E  /  TRIP HIM SAFELY"
 elif phase == "attack":
  elapsed += delta
  robber_actor.position = robber_actor.position.lerp(player_actor.position + Vector3(0, 0, -0.75), minf(delta * 4.0, 1.0))
  robber_actor.rotation.x = lerpf(PI / 2.0, 0.0, clampf(elapsed / 0.55, 0.0, 1.0))
  robber_actor.animate_motion(delta, 1.2)
  if elapsed >= 1.0:
   phase = "evade"
   subtitles.text = "He lunges. You have plenty of time to read the movement."
   prompt.text = "PRESS A OR D  /  STEP ASIDE"
 elif phase == "reveal":
  elapsed += delta
  ruby_actor.position = ruby_actor.position.lerp(Vector3(-1.8, 0, -2.6), minf(delta * 2.0, 1.0))
  ruby_actor.animate_motion(delta, 0.5)
  if elapsed >= 2.0:
   subtitles.text = "RUBY: " + chosen_name + ", I personally recommended you to BLACKLINE. They want you at the Civic Evaluation Annex for Initiation."
   prompt.text = "The robber is safely restrained. No target or key is credited by this opening."
   continue_button.visible = true
   continue_button.grab_focus()
   phase = "handoff"

func _unhandled_input(event: InputEvent) -> void:
 if event.is_echo(): return
 if phase == "trip" and event.is_action_pressed("interact"):
  player_actor.position.z = 1.1
  robber_actor.position = Vector3(0.5, 0.05, -0.8)
  robber_actor.rotation.x = PI / 2.0
  phase = "attack"
  elapsed = 0.0
  subtitles.text = "The trip stops him; he scrambles up and swings at you."
  prompt.text = "Stay calm."
  get_viewport().set_input_as_handled()
 elif phase == "evade" and (event.is_action_pressed("move_left") or event.is_action_pressed("move_right")):
  var side := -1.0 if event.is_action_pressed("move_left") else 1.0
  player_actor.position.x = side * 1.25
  robber_actor.position = player_actor.position + Vector3(-side * 0.35, 0, -0.45)
  robber_actor.rotation.x = 0.0
  robber_actor.rotation.y = PI / 2.0 * side
  phase = "restrain"
  subtitles.text = "You sidestep the swing and take control without injury."
  prompt.text = "PRESS E  /  RESTRAIN HIM"
  get_viewport().set_input_as_handled()
 elif phase == "restrain" and event.is_action_pressed("interact"):
  robber_actor.position.z -= 0.35
  robber_actor.rotation.x = PI / 2.0
  ruby_actor.position = Vector3(-3.8, 0, -2.0)
  phase = "reveal"
  elapsed = 0.0
  subtitles.text = "The robber is subdued without injury. Ruby catches up and reveals her BLACKLINE identity."
  prompt.text = ""
  get_viewport().set_input_as_handled()

func _finish_opening() -> void:
 if phase != "handoff": return
 if not Campaign.finish_bus_stop(chosen_name):
  prompt.text = "The campaign could not save this handoff. Check available storage and try again."

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
