extends "res://scripts/world/hotel.gd"
## The fictional Civic Evaluation Annex uses the existing player, NPC and interactions.
const WAITING_CHAIR := preload("res://assets/kenney_furniture/chairCushion.glb")
var robot: Interactable
var patrol_clock: float = 0.0
var robot_alert: bool = false
var robot_light: StandardMaterial3D

func mission_id() -> String:
 return "initiation"

func mission_path() -> String:
 return "res://resources/initiation_mission.json"

func safe_position(p: Vector3) -> bool:
 if not p.is_finite() or absf(p.x) > 14.0 or p.y < 0.0 or p.y > 3.0 or absf(p.z) > 9.0: return false
 for boundary: float in [2.0, 7.0]:
  if absf(p.x - boundary) < 0.44 and not (absf(p.z) >= 2.35 and absf(p.z) <= 3.65): return false
 return true

func _build_environment() -> void:
 var environment := WorldEnvironment.new()
 var settings := Environment.new()
 settings.background_mode = Environment.BG_COLOR
 settings.background_color = Color(0.09, 0.12, 0.14)
 settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 settings.ambient_light_color = Color(0.70, 0.76, 0.76)
 settings.ambient_light_energy = 0.75
 environment.environment = settings
 add_child(environment)
 var light := DirectionalLight3D.new()
 light.rotation_degrees = Vector3(-55, -25, 0)
 light.light_energy = 0.8
 light.add_to_group("quality_lights")
 light.shadow_enabled = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["shadows"])
 add_child(light)
 _box(Vector3(0, -0.15, 0), Vector3(30, 0.3, 20), Color(0.46, 0.48, 0.45))
 _box(Vector3(-15, 1.5, 0), Vector3(0.25, 3, 20), Color(0.48, 0.50, 0.47))
 _box(Vector3(15, 1.5, 0), Vector3(0.25, 3, 20), Color(0.48, 0.50, 0.47))
 _box(Vector3(0, 1.5, -10), Vector3(30, 3, 0.25), Color(0.48, 0.50, 0.47))
 _box(Vector3(0, 1.5, 10), Vector3(30, 3, 0.25), Color(0.48, 0.50, 0.47))
 # Split assessment, observation and controlled training areas; two routes each.
 for boundary: float in [2.0, 7.0]:
  _box(Vector3(boundary, 1.5, -7), Vector3(0.2, 3, 6), Color(0.38, 0.42, 0.42))
  _box(Vector3(boundary, 1.5, 0), Vector3(0.2, 3, 4), Color(0.38, 0.42, 0.42))
  _box(Vector3(boundary, 1.5, 7), Vector3(0.2, 3, 6), Color(0.38, 0.42, 0.42))
  # Cased portal returns, protected corners and low egress strips make the two
  # routes legible without reducing the tested 1.3 m clear passage width.
  for portal_z: float in [-3.65,-2.35,2.35,3.65]: _box(Vector3(boundary,1.48,portal_z),Vector3(0.16,2.96,0.10),Color(0.29,0.37,0.37),false)
  for portal_center: float in [-3.0,3.0]:
   _box(Vector3(boundary,2.99,portal_center),Vector3(0.18,0.12,1.36),Color(0.55,0.66,0.61),false)
   _box(Vector3(boundary,0.07,portal_center),Vector3(0.26,0.025,1.22),Color(0.79,0.57,0.28),false)
 _box(Vector3(-7, 0.01, 0), Vector3(15, 0.02, 19), Color(0.48, 0.49, 0.46), false)
 _box(Vector3(4.5, 0.01, 0), Vector3(4.5, 0.02, 19), Color(0.49, 0.52, 0.48), false)
 _box(Vector3(11, 0.01, 0), Vector3(7.5, 0.02, 19), Color(0.45, 0.44, 0.40), false)
 # Reception and waiting: a sign-in counter faces two visitor seats, leaving
 # the evidence desk and the security route open and readable.
 _box(Vector3(-11.2,0.50,-7.8),Vector3(4.2,1.0,1.05),Color(0.30,0.24,0.18),false)
 _box(Vector3(-11.2,1.04,-7.8),Vector3(4.0,0.10,0.96),Color(0.58,0.49,0.35),false)
 for seat_x: float in [-12.0,-9.4]: _place_waiting_chair(Vector3(seat_x,0.0,0.2),PI)
 _box(Vector3(-10.0,1.45,-9.76),Vector3(5.2,0.65,0.10),Color(0.15,0.25,0.27),false)
 _box(Vector3(-10.0,1.48,-9.68),Vector3(4.9,0.48,0.035),Color(0.34,0.48,0.47),false)
 _wayfinding("CIVIC EVALUATION  /  RECEPTION",Vector3(-10.0,2.1,-9.65),0.0)
 # Observation console: staff have paired screens, cable wells and a shared
 # worktop aligned to the sensor-log record, not a generic waiting-room block.
 _box(Vector3(4.5,0.76,0.95),Vector3(3.8,0.14,1.2),Color(0.23,0.26,0.25),false)
 for monitor_x: float in [3.45,4.5,5.55]:
  _box(Vector3(monitor_x,1.30,0.52),Vector3(0.78,0.56,0.08),Color(0.12,0.20,0.22),false)
  _box(Vector3(monitor_x,1.31,0.47),Vector3(0.67,0.40,0.025),Color(0.20,0.58,0.57),false)
  _box(Vector3(monitor_x,0.99,0.55),Vector3(0.12,0.14,0.10),Color(0.18,0.25,0.27),false)
 _box(Vector3(5.92,1.12,0.90),Vector3(0.52,0.44,0.72),Color(0.19,0.27,0.29),false)
 _wayfinding("OBSERVATION  /  SENSOR LOG",Vector3(4.5,2.55,-9.70),0.0)
 # Controlled practice bay: replace a bare box with floor mats, a padded
 # target stand, equipment lockers and painted lane marks; dispatch stays clear.
 _box(Vector3(11.0,0.035,-2.2),Vector3(6.2,0.05,6.0),Color(0.24,0.29,0.29),false)
 for lane_x: float in [9.0,11.0,13.0]: _box(Vector3(lane_x,0.07,-2.2),Vector3(0.05,0.018,5.2),Color(0.72,0.68,0.52),false)
 _box(Vector3(13.3,1.2,-7.7),Vector3(1.8,2.4,0.34),Color(0.23,0.29,0.29),false)
 _box(Vector3(13.3,1.2,-7.48),Vector3(1.54,1.75,0.06),Color(0.72,0.58,0.40),false)
 for edge: float in [-0.48,0.48]: _box(Vector3(13.3+edge,1.22,-7.40),Vector3(0.045,1.4,0.035),Color(0.84,0.75,0.55),false)
 _box(Vector3(13.3,0.9,-7.34),Vector3(0.10,0.10,0.03),Color(0.72,0.24,0.16),false)
 _box(Vector3(8.8,0.65,7.8),Vector3(2.2,1.3,0.75),Color(0.26,0.29,0.27),false)
 _wayfinding("CONTROLLED PRACTICE  /  DISPATCH",Vector3(11.0,2.5,-9.70),0.0)
 # Legacy equipment and evidence surfaces remain in their original locations.
 _box(Vector3(-10, 0.45, -7), Vector3(3, 0.9, 1), Color(0.30, 0.27, 0.23), false)
 _box(Vector3(4.5, 0.45, -7), Vector3(2, 0.9, 1), Color(0.28, 0.32, 0.32), false)
 _box(Vector3(10, 0.45, 7), Vector3(3, 0.9, 1), Color(0.32, 0.30, 0.25), false)
 _box(Vector3(0, 3.05, 0), Vector3(30, 0.1, 20), Color(0.28, 0.31, 0.31), false)
 for x: float in [-10.0, -3.0, 4.5, 10.5]:
  _box(Vector3(x, 2.95, 0), Vector3(1.5, 0.06, 0.22), Color(0.75, 0.88, 0.86), false)
  _box(Vector3(x, 1.6, -9.83), Vector3(1.6, 0.8, 0.04), Color(0.14, 0.25, 0.27), false)
 # Ceiling service spines and paired luminous diffusers follow the room axes;
 # vents, access hatches and wall-base protection anchor the scale.
 for hall_x: float in [-10.0,-3.0,4.5,10.5]:
  _box(Vector3(hall_x,2.88,0),Vector3(0.16,0.18,17.2),Color(0.19,0.25,0.26),false)
  for light_z: float in [-5.8,0.0,5.8]:
   _box(Vector3(hall_x,2.79,light_z),Vector3(1.15,0.07,2.7),Color(0.76,0.83,0.77),false)
   _box(Vector3(hall_x,2.70,light_z-1.38),Vector3(1.35,0.07,0.08),Color(0.32,0.40,0.39),false)
  _box(Vector3(hall_x+2.5,2.60,-7.0),Vector3(0.58,0.28,1.25),Color(0.27,0.35,0.35),false)
  _box(Vector3(hall_x+2.5,2.43,-7.0),Vector3(0.42,0.035,0.82),Color(0.54,0.63,0.58),false)
 for wall_x: float in [-14.82,-0.12,2.12,6.88,14.82]:
  _box(Vector3(wall_x,0.16,0),Vector3(0.08,0.25,18.9),Color(0.25,0.34,0.34),false)
  _box(Vector3(wall_x,2.96,0),Vector3(0.12,0.13,18.9),Color(0.34,0.40,0.39),false)
 for boundary: float in [2.0, 7.0]:
  for z: float in [-3.0, 3.0]:
   _box(Vector3(boundary, 2.85, z), Vector3(0.3, 0.3, 2), Color(0.24, 0.29, 0.30), false)
 var region := NavigationRegion3D.new()
 var nav := NavigationMesh.new()
 var xs := [-14.5, 1.5, 2.5, 6.5, 7.5, 14.5]
 var zs := [-9.5, -3.65, -2.35, 2.35, 3.65, 9.5]
 var vertices := PackedVector3Array()
 for z: float in zs:
  for x: float in xs: vertices.append(Vector3(x, 0, z))
 nav.vertices = vertices
 for row: int in range(zs.size() - 1):
  for col: int in range(xs.size() - 1):
   if col in [1, 3] and row not in [1, 3]: continue
   var a: int = row * xs.size() + col
   nav.add_polygon(PackedInt32Array([a, a + xs.size(), a + xs.size() + 1, a + 1]))
 region.navigation_mesh = nav
 add_child(region)

func _place_waiting_chair(at: Vector3, yaw: float) -> void:
 var placement := Node3D.new()
 placement.name = "AssessmentWaitingChairPlacement"
 placement.add_to_group("assessment_waiting_chair")
 placement.position = at
 placement.rotation.y = yaw
 add_child(placement)
 var chair := WAITING_CHAIR.instantiate() as Node3D
 chair.scale = Vector3(1.25,1.25,1.25)
 chair.position = Vector3(-0.10,0.0,0.10)*chair.scale
 placement.add_child(chair)

func _wayfinding(text: String, at: Vector3, yaw: float) -> void:
 var sign := Label3D.new()
 sign.name = "AssessmentWayfindingSign"
 sign.add_to_group("assessment_wayfinding")
 sign.text = text
 sign.position = at
 sign.rotation.y = yaw
 sign.font_size = 20
 sign.pixel_size = 0.004
 sign.modulate = Color(0.83,0.86,0.78)
 add_child(sign)

func _build_player() -> void:
 super._build_player()
 player.position = Vector3(-13, 0.05, 7)

func _build_npcs() -> void:
 _guard("Elias Ward", Vector3(-7, 0.05, 0), [ScheduleEntry.new(Vector3(-6, 0, -2), "waiting", 3), ScheduleEntry.new(Vector3(4, 0, 3), "working", 4)])
 _guard("Tessa Rao", Vector3(10, 0.05, 0), [ScheduleEntry.new(Vector3(10, 0, -2), "waiting", 3), ScheduleEntry.new(Vector3(5, 0, -3), "working", 4)])

func _guard(identity: String, spawn: Vector3, route: Array[ScheduleEntry]) -> void:
 var profile := NpcProfile.new()
 profile.identity = identity
 profile.occupation = "security"
 profile.alertness = 0.7
 profile.schedule = route
 var guard := HotelNpc.new()
 guard.profile = profile
 guard.player = player
 guard.trespass_notice.connect(_on_trespass_notice)
 guard.position = spawn
 add_child(guard)
 npcs.append(guard)

func _build_interactions() -> void:
 for record: Dictionary in mission.available_records:
  _add_interactable(_vector(record["position"]), record["label"], "clue", record["id"], Color(0.9, 0.72, 0.34))
 _add_interactable(Vector3(-5, 0, -2), "Disable assessment unit", "robot", "disable_assessment_unit", Color(0.38, 0.73, 0.83))
 robot = interactables.back()
 var hit_area := Area3D.new()
 hit_area.collision_layer = 2
 hit_area.collision_mask = 0
 var hit_shape := CollisionShape3D.new()
 var shape := CapsuleShape3D.new()
 shape.radius = 0.35
 shape.height = 1.3
 hit_shape.shape = shape
 hit_shape.position.y = 0.65
 hit_area.add_child(hit_shape)
 robot.add_child(hit_area)
 # Distinct abstract machine silhouette, separate from the human NPC meshes.
 var head := MeshInstance3D.new()
 var head_mesh := SphereMesh.new()
 head_mesh.radius = 0.26
 head_mesh.height = 0.52
 head.mesh = head_mesh
 head.position.y = 1.05
 var robot_material := StandardMaterial3D.new()
 robot_material.albedo_color = Color(0.16, 0.55, 0.65)
 robot_material.emission_enabled = true
 robot_material.emission = Color(0.08, 0.3, 0.38)
 robot_light = robot_material
 head.material_override = robot_material
 robot.add_child(head)
 # Jointed, machine-like silhouette: two legs, shoulders and a bright sensor.
 for x: float in [-0.21, 0.21]:
  _robot_part(Vector3(x, 0.28, 0), Vector3(0.13, 0.56, 0.18), robot_material)
  _robot_part(Vector3(x * 1.9, 0.70, 0), Vector3(0.16, 0.46, 0.18), robot_material)
 _robot_part(Vector3(0, 1.07, -0.245), Vector3(0.28, 0.08, 0.04), robot_material)
 _add_interactable(Vector3(-13, 0, 7), "Complete assessment", "extract", "exit", Color(0.4, 0.8, 0.5))

func _robot_part(pos: Vector3, size: Vector3, material: Material) -> void:
 var visual := MeshInstance3D.new()
 var mesh := BoxMesh.new()
 mesh.size = size
 visual.mesh = mesh
 visual.position = pos
 visual.material_override = material
 robot.add_child(visual)

func _on_interaction(object: Interactable) -> void:
 if object.kind == "robot":
  if mission.mark_action(object.identifier):
   object.used = true
   message = "Ruby: Unit offline. Collect the three records and return to the exit."
  return
 super._on_interaction(object)

func _physics_process(delta: float) -> void:
 if not robot: return
 if robot.used:
  robot_alert = false
  robot_light.emission = Color(0.03, 0.03, 0.03)
  return
 robot_alert = _clear_reach(robot.global_position, 3.0)
 patrol_clock += delta * (0.4 if robot_alert else 1.0)
 robot.position.x = -5.0 + sin(patrol_clock * 0.6) * 1.4
 if robot_alert:
  var toward := player.global_position - robot.global_position
  robot.rotation.y = atan2(-toward.x, -toward.z)
 robot_light.emission = Color(0.8, 0.18, 0.08) if robot_alert else Color(0.08, 0.3, 0.38)
