extends Node3D
## Original fictional extensions attached to the shared city, one per mission.
const CONSTRUCTION := preload("res://scripts/world/construction_kit.gd")
const CITY_FACADE_SHADER := preload("res://shaders/city_facade.gdshader")
const CITY_PAVING_SHADER := preload("res://shaders/city_paving.gdshader")
## Local +Z points outwards. Collision, lighting and readable passages are authored.
var operation_id := ""
var mesh_cache: Dictionary = {}
var material_cache: Dictionary = {}
var intel_position := Vector3(0,3.3,57)
var uniform_position := Vector3(-17,4.0,19)
var beacon: OmniLight3D
var beacon_clock: float = 0.0

func _box(pos: Vector3, size: Vector3, color: Color, solid: bool = false) -> Node3D:
 var holder: Node3D = StaticBody3D.new() if solid else Node3D.new()
 holder.position = pos
 add_child(holder)
 var visual := MeshInstance3D.new()
 if not mesh_cache.has(size):
  var mesh := BoxMesh.new()
  mesh.size = size
  mesh_cache[size] = mesh
 visual.mesh = mesh_cache[size]
 if not material_cache.has(color):
  var material := StandardMaterial3D.new()
  material.albedo_color = color
  material.roughness = 0.8
  material_cache[color] = material
 visual.material_override = material_cache[color]
 if not solid: visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 holder.add_child(visual)
 if solid:
  var collider := CollisionShape3D.new()
  var shape := BoxShape3D.new()
  shape.size = size
  collider.shape = shape
  holder.add_child(collider)
 return holder

func _sign(text: String, pos: Vector3, yaw: float = 0.0) -> void:
 var label := Label3D.new()
 label.text = text
 label.position = pos
 label.rotation.y = yaw
 label.font_size = 32
 label.pixel_size = 0.005
 label.modulate = Color(0.95,0.86,0.67)
 add_child(label)

func build() -> void:
 var market := operation_id == "the_streets"
 var business := operation_id == "the_district"
 var paving := Color(0.39,0.37,0.34) if market else (Color(0.36,0.40,0.40) if business else Color(0.33,0.40,0.41))
 var wall := Color(0.63,0.53,0.41) if market else (Color(0.47,0.56,0.57) if business else Color(0.55,0.54,0.48))
 var accent := Color(0.73,0.27,0.18) if market else (Color(0.24,0.48,0.49) if business else Color(0.18,0.40,0.49))
 var dark := Color(0.19,0.25,0.26)
 var ground := _box(Vector3(0,-0.2,35),Vector3(70,0.4,70),paving,true)
 ground.name = "NeighbourhoodGround"
 var paving_material := ShaderMaterial.new()
 paving_material.shader = CITY_PAVING_SHADER
 paving_material.set_shader_parameter("paving_tint",paving)
 (ground.get_child(0) as MeshInstance3D).material_override = paving_material
 # Solid boundaries and a 12m gateway back to the existing city.
 for x: float in [-35.0,35.0]: _box(Vector3(x,2,35),Vector3(0.3,4,70),dark,true)
 if operation_id == "the_harbour":
  _box(Vector3(0,0.55,70),Vector3(70,1.1,0.3),dark,true)
 else: _box(Vector3(0,2,70),Vector3(70,4,0.3),dark,true)
 for x: float in [-20.5,20.5]: _box(Vector3(x,2,0),Vector3(29,4,0.3),dark,true)
 _box(Vector3(0,0.03,35),Vector3(9,0.05,70),paving.darkened(0.35))
 for z: float in [10.0,30.0,50.0,65.0]:
  _box(Vector3(0,0.04,z),Vector3(69,0.06,6),paving.lightened(0.10))
  for x: float in [-3.0,-1.5,0.0,1.5,3.0]: _box(Vector3(x,0.08,z),Vector3(0.7,0.02,2.8),Color(0.73,0.71,0.62))
 # Open rooms have front/back access and separate pedestrian alleys.
 for x: float in [-17.0,17.0]:
  for z: float in [18.0,38.0,58.0]:
   if operation_id == "the_harbour" and x == -17.0 and z == 38.0:
    _harbour_tower()
    continue
   # Different open plazas interrupt the grid and preserve varied views.
   if (operation_id == "the_harbour" and x > 0.0 and z == 58.0) or (operation_id == "the_district" and x < 0.0 and z == 38.0):
    _box(Vector3(x,0.035,z),Vector3(10,0.05,10),paving.lightened(0.15))
    _box(Vector3(x-3,0.5,z+3),Vector3(2.5,0.13,0.8),accent,true)
    _box(Vector3(x+3,0.45,z-3),Vector3(1.1,0.9,1.1),wall.darkened(0.25))
    _box(Vector3(x+3,1.4,z-3),Vector3(1.7,1.4,1.7),Color(0.25,0.43,0.29))
    continue
   _room(x,z,wall,accent,dark)
 # A walkable second storey over the south-west room has its own exterior
 # approach; it is not merely a visual rooftop facade.
 var stair := _box(Vector3(-17,1.98,8),Vector3(3.0,0.18,10.8),paving.lightened(0.10),true)
 stair.rotation.x = -atan(3.95/10.0)
 stair.name = "UpperOfficeRamp"
 if business:
  # A taller, non-interactive commercial skyline over the offices.
  for x: float in [-17.0,17.0]:
   _box(Vector3(x,11.0,18),Vector3(7,8,7),wall.darkened(0.12))
   for y: float in [8.5,10.5,12.5,14.0]:
    for dx: float in [-2.0,0.0,2.0]:
     _box(Vector3(x+dx,y,21.55),Vector3(1.1,1.2,0.06),Color(0.24,0.40,0.44))
 # Each district's side lanes carry different everyday activities; the
 # objects are kept clear of the central street and both room entrances.
 for side: float in [-1.0,1.0]:
  for z: float in [9.0,29.0,49.0]:
   var x := side * 27.0
   if market:
    _box(Vector3(x,0.5,z),Vector3(3.6,1.0,1.8),Color(0.39,0.26,0.17),true)
    _box(Vector3(x,2.4,z),Vector3(4.0,0.12,2.2),accent)
    for dx: float in [-1.5,1.5]: _box(Vector3(x+dx,1.65,z),Vector3(0.1,1.5,0.1),dark)
    for dx: float in [-1.0,0.0,1.0]: _box(Vector3(x+dx,1.12,z),Vector3(0.65,0.22,0.6),Color(0.70,0.48,0.24) if dx != 0.0 else Color(0.48,0.59,0.29))
   elif business:
    _box(Vector3(x,0.45,z),Vector3(3.2,0.13,0.8),Color(0.43,0.34,0.24),true)
    for dx: float in [-1.2,1.2]: _box(Vector3(x+dx,0.2,z),Vector3(0.15,0.4,0.7),dark)
    _box(Vector3(x+side*2.4,0.35,z),Vector3(0.8,0.7,0.8),Color(0.45,0.42,0.34))
    _box(Vector3(x+side*2.4,1.0,z),Vector3(1.5,1.2,1.5),Color(0.26,0.43,0.29))
   else:
    _box(Vector3(x,0.6,z),Vector3(2.0,1.2,1.4),Color(0.45,0.35,0.24),true)
    _box(Vector3(x,1.28,z),Vector3(1.7,0.08,1.2),Color(0.59,0.48,0.32))
    for dx: float in [-0.7,0.7]: _box(Vector3(x+dx,0.62,z-0.72),Vector3(0.08,1.1,0.08),dark)
 # Roof viewing platform with a solid low-gradient ramp and useful intel.
 var ramp := _box(Vector3(0,1.42,43),Vector3(5,0.18,10.5),paving.lightened(0.12),true)
 ramp.rotation.x = -atan(3.0/10.0)
 ramp.name = "NeighbourhoodRamp"
 _box(Vector3(0,2.85,56),Vector3(10,0.3,16),paving.lightened(0.1),true)
 for x: float in [-4.9,4.9]:
  _box(Vector3(x,3.55,56),Vector3(0.12,1.2,16),dark,true)
 _box(Vector3(0,3.55,63.9),Vector3(10,1.2,0.12),dark,true)
 _box(Vector3(-3.0,3.5,60),Vector3(1.2,1.0,0.8),accent,true)
 _sign("LOOKOUT / INTEL",Vector3(0,4.5,62.5),PI)
 # Bounded, non-shadow-casting practicals, grouped for preset control.
 for z: float in [16.0,38.0,60.0]:
  for x: float in [-7.0,7.0]:
   _box(Vector3(x,1.9,z),Vector3(0.12,3.8,0.12),dark)
   _box(Vector3(x,3.8,z),Vector3(0.7,0.1,0.55),Color(0.96,0.78,0.49))
   var light := OmniLight3D.new()
   light.position = Vector3(x,3.6,z)
   light.light_color = Color(1.0,0.77,0.53) if market else Color(0.74,0.86,1.0)
   light.light_energy = 0.3
   light.omni_range = 6.0
   light.shadow_enabled = false
   light.add_to_group("quality_practicals")
   light.visible = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["practicals"])
   add_child(light)
 # One low-cost animated beacon gives each neighbourhood a changing light
 # without multiplying shadow maps or overlapping large light volumes.
 beacon = OmniLight3D.new()
 beacon.position = Vector3(0,4.1,8)
 beacon.light_color = accent.lightened(0.45)
 beacon.light_energy = 0.32
 beacon.omni_range = 7.0
 beacon.shadow_enabled = false
 beacon.add_to_group("quality_practicals")
 beacon.visible = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["practicals"])
 add_child(beacon)
 # The corridor navmesh deliberately excludes the new buildings and ramp.
 var region := NavigationRegion3D.new()
 region.name = "NeighbourhoodStreetNavigation"
 var nav := NavigationMesh.new()
 nav.vertices = PackedVector3Array([Vector3(-4,0,0),Vector3(4,0,0),Vector3(4,0,37),Vector3(-4,0,37)])
 nav.add_polygon(PackedInt32Array([0,3,2,1]))
 region.navigation_mesh = nav
 add_child(region)
 # Local, short social routines remain on the obstacle-free central strip.
 var scene := get_parent()
 for i: int in range(3):
  var start := to_global(Vector3(-2.2 + float(i)*2.2,0.05,12.0 + float(i)*5.0))
  var finish := to_global(Vector3(-2.2 + float(i)*2.2,0.05,25.0 + float(i)*3.0))
  var identity := ("Market visitor " if market else ("Office worker " if business else "Quay visitor ")) + str(i+1)
  scene.call("_target", identity, "employee" if i == 1 else "civilian", start, finish)
 _sign("MARKET LANES" if market else ("COMMERCIAL QUARTER" if business else "WATERFRONT PROMENADE"),Vector3(0,4,7),PI)
 if not market and not business:
  # The shared world renderer supplies the far-water plane beyond this public
  # promenade, so this annex only frames the accessible edge with a railing.
  for x: float in [-25.0,-15.0,-5.0,5.0,15.0,25.0]:
   _box(Vector3(x,0.9,67.5),Vector3(0.1,1.8,0.1),Color(0.68,0.72,0.67))
  _box(Vector3(0,1.65,67.5),Vector3(60,0.08,0.08),Color(0.68,0.72,0.67))

func _harbour_tower() -> void:
 # Five accessible, moderate-height levels (about 16 m), with a separate
 # executive suite, street-facing lobby, meeting floors and a switchback stair.
 var center := Vector3(-17, 0, 38)
 var stone := Color(0.45,0.51,0.51)
 var trim := Color(0.15,0.23,0.26)
 var glass_tint := Color(0.34,0.64,0.70,0.64)
 for level: int in range(5):
  var floor_y := float(level) * 3.2
  _box(center + Vector3(0,floor_y-0.12,0),Vector3(18,0.24,20),stone.darkened(0.08),true)
  # Solid side and rear shells; the front lobby has an open, readable entrance.
  _box(center + Vector3(-8.85,floor_y+1.6,0),Vector3(0.3,3.2,20),stone,true)
  _box(center + Vector3(8.85,floor_y+1.6,0),Vector3(0.3,3.2,20),stone,true)
  _box(center + Vector3(0,floor_y+1.6,9.85),Vector3(18,3.2,0.3),stone,true)
  if level == 0:
   for side: float in [-1.0,1.0]:
    _box(center + Vector3(side*6.25,floor_y+1.6,-9.85),Vector3(5.5,3.2,0.3),stone,true)
   _box(center + Vector3(0,floor_y+3.02,-9.85),Vector3(6.8,0.36,0.3),trim,true)
   for x: float in [-4.0,4.0]:
    var pane := DestructibleGlass.new()
    pane.position = center + Vector3(x,floor_y+1.65,-9.66)
    pane.configure(Vector3(2.0,2.55,0.08),glass_tint)
    add_child(pane)
  else:
   _box(center + Vector3(0,floor_y+0.24,-9.85),Vector3(18,0.48,0.3),trim,true)
   _box(center + Vector3(0,floor_y+2.98,-9.85),Vector3(18,0.44,0.3),trim,true)
   for x: float in [-5.7,-2.0,2.0,5.7]:
    _box(center + Vector3(x,floor_y+1.6,-9.85),Vector3(0.36,2.75,0.3),trim,true)
   for x: float in [-3.85,0.0,3.85]:
    var pane := DestructibleGlass.new()
    pane.position = center + Vector3(x,floor_y+1.62,-9.66)
    pane.configure(Vector3(3.2,2.25,0.08),glass_tint)
    add_child(pane)
  for side: float in [-1.0,1.0]:
   _box(center + Vector3(side*9.08,floor_y+1.6,0),Vector3(0.08,2.65,19),Color(0.27,0.43,0.48))
  # Floor-local navigation keeps the executive's short work routine on the
  # accessible level rather than asking the street agent to jump storeys.
  var floor_region := NavigationRegion3D.new()
  floor_region.name = "CorporateFloorNavigation_%d" % level
  floor_region.position = center + Vector3(0,floor_y,0)
  var floor_nav := NavigationMesh.new()
  floor_nav.vertices = PackedVector3Array([Vector3(-7.4,0,-8.5),Vector3(7.4,0,-8.5),Vector3(7.4,0,8.5),Vector3(-7.4,0,8.5)])
  floor_nav.add_polygon(PackedInt32Array([0,3,2,1]))
  floor_region.navigation_mesh = floor_nav
  add_child(floor_region)
  # Switchback ramp flights are built from collision-backed, sloped slabs.
  if level < 4:
   var angle := atan(3.2 / 9.0)
   var stair_x := -23.6 if level % 2 == 0 else -20.8
   var flight := _box(center + Vector3(stair_x+17.0,floor_y+1.6,0),Vector3(2.25,sqrt(3.2*3.2+9.0*9.0),9.0),Color(0.36,0.43,0.44),true)
   flight.rotation.x = -angle if level % 2 == 0 else angle
   for side: float in [-1.0,1.0]:
    _box(flight.position + Vector3(side*1.15,0,0),Vector3(0.08,1.0,9.0),trim)
  var level_sign := Label3D.new()
  level_sign.text = ["LOBBY  /  RECEPTION", "OFFICES  /  FINANCE", "MEETING FLOOR", "OPERATIONS", "EXECUTIVE SUITE"][level]
  level_sign.position = center + Vector3(0,2.6,floor_y*0.0-8.5)
  level_sign.font_size = 20
  level_sign.pixel_size = 0.005
  level_sign.modulate = Color(0.88,0.78,0.58)
  level_sign.rotation.y = PI
  add_child(level_sign)
 # Reception, working offices, meeting suite and the private executive office.
 _box(center + Vector3(3.0,0.52,-5.0),Vector3(6.0,1.0,1.5),Color(0.28,0.23,0.18),true)
 _box(center + Vector3(3.0,1.06,-5.0),Vector3(5.8,0.12,1.3),Color(0.55,0.43,0.29))
 for floor_index: int in range(1,4):
  var floor_y := float(floor_index)*3.2
  _box(center + Vector3(2.0,floor_y+0.55,2.6),Vector3(4.0,1.1,1.5),Color(0.29,0.26,0.22),true)
  _box(center + Vector3(-3.8,floor_y+0.50,-2.7),Vector3(3.0,1.0,1.3),Color(0.30,0.25,0.20),true)
  for side: float in [-1.0,1.0]:
   _box(center + Vector3(2.0+side*2.7,floor_y+0.55,2.6),Vector3(0.55,1.0,0.55),Color(0.31,0.38,0.36))
 # Executive office furniture; maintain an unobstructed walk from the stair.
 _box(center + Vector3(-13.0+17.0,13.35,3.8),Vector3(5.2,0.9,1.6),Color(0.24,0.20,0.16),true)
 _box(center + Vector3(-12.8+17.0,13.85,3.8),Vector3(4.8,0.12,1.4),Color(0.49,0.39,0.26))
 _box(center + Vector3(3.4,13.25,4.0),Vector3(3.8,0.72,2.4),Color(0.32,0.29,0.25),true)
 _box(center + Vector3(3.4,13.65,4.0),Vector3(3.4,0.12,2.0),Color(0.47,0.40,0.31))
 _sign("VANTAGE HOUSE  /  EXECUTIVE ENTRANCE",center+Vector3(0,6.4,-10.2),PI)
 _sign("PRIVATE OFFICE  /  LEVEL 05",center+Vector3(-17.0,15.3,4.2),PI)
 # Reception security and office staff give the tower a lived-in schedule.
 var scene := get_parent()
 scene.call("_target","Vantage House lobby security","security",to_global(center+Vector3(-3,0.05,2)),to_global(center+Vector3(-3,0.05,-2)))
 scene.call("_target","Finance floor analyst","employee",to_global(center+Vector3(3,3.25,3)),to_global(center+Vector3(3,3.25,-2)))
 scene.call("_target","Executive assistant","employee",to_global(center+Vector3(-3,12.85,-2)),to_global(center+Vector3(-3,12.85,2)))

func _room(x: float, z: float, wall: Color, accent: Color, dark: Color) -> void:
 var storefront_side := -1.0 if x > 0.0 else 1.0
 for side: float in [-1.0,1.0]:
  _box(Vector3(x,1.9,z+side*5.0),Vector3(10,3.8,0.2),wall,true)
  if side == storefront_side:
   _build_storefront_wall(x,z,side,wall,accent,dark)
  else:
   _box(Vector3(x+side*5,1.9,z),Vector3(0.2,3.8,10),wall,true)
 _box(Vector3(x,3.85,z),Vector3(10,0.2,10),wall.darkened(0.18),true)
 _box(Vector3(x,0.025,z),Vector3(9.7,0.04,9.7),wall.lightened(0.10))
 _box(Vector3(x,0.5,z-3.5),Vector3(4,1,1),dark,true)
 _box(Vector3(x,1.07,z-3.5),Vector3(3.8,0.08,0.9),accent)
 # Differentiated interior storytelling, placed at the rear wall.
 for dx: float in [-2.0,0.0,2.0]:
  if operation_id == "the_streets":
   _box(Vector3(x+dx,1.22,z-3.5),Vector3(0.55,0.22,0.5),Color(0.75,0.57,0.30))
   _box(Vector3(x+dx,2.7,z-4.86),Vector3(1.1,0.8,0.04),accent.lightened(0.2))
  elif operation_id == "the_district":
   _box(Vector3(x+dx,1.32,z-3.5),Vector3(0.55,0.5,0.1),Color(0.19,0.33,0.36))
   _box(Vector3(x+dx,2.55,z-4.86),Vector3(1.2,0.9,0.04),Color(0.67,0.68,0.59))
  else:
   _box(Vector3(x+dx,1.25,z-3.5),Vector3(0.5,0.32,0.5),Color(0.45,0.32,0.21))
   _box(Vector3(x+dx,2.55,z-4.86),Vector3(1.2,0.9,0.04),Color(0.36,0.49,0.52))
 if x == -17.0 and z == 18.0:
  for side: float in [-1.0,1.0]:
   _box(Vector3(x+side*5,5.55,z),Vector3(0.18,3.2,10),wall,true)
   _box(Vector3(x+side*3.25,5.55,z-5),Vector3(3.5,3.2,0.18),wall,true)
  _box(Vector3(x,5.55,z+5),Vector3(10,3.2,0.18),wall,true)
  _box(Vector3(x,7.25,z),Vector3(10,0.2,10),dark,true)
  _box(Vector3(x+3,4.45,z+3),Vector3(2,0.9,1),accent,true)
  _sign("UPPER SERVICE / STAFF",Vector3(x,6.8,z-4.86),PI)
 else:
  for dx: float in [-3.0,0.0,3.0]:
  var upper_shell := _box(Vector3(x+dx,5.5,z),Vector3(2.2,3.0,8),wall.darkened(0.08))
  upper_shell.name = "DistrictUpperFacadeShell"
  var upper_visual := upper_shell.get_child(0) as MeshInstance3D
  var facade_material := ShaderMaterial.new()
  facade_material.shader = CITY_FACADE_SHADER
  facade_material.set_shader_parameter("facade_tint",wall.darkened(0.08))
  facade_material.set_shader_parameter("facade_seed",absf(x*13.0+z*7.0+dx))
  upper_visual.material_override = facade_material
  _box(Vector3(x+dx,5.6,z+4.05),Vector3(1.6,1.7,0.06),Color(0.21,0.34,0.37))
 # The upper storey is a real, visible volume rather than one blank silhouette:
 # framed glazing wraps the side and rear elevations, with a continuous slab
 # edge and a restrained service-level air-conditioning unit.
 var upper_glass := Color(0.16,0.31,0.36) if operation_id == "the_streets" else (Color(0.22,0.39,0.42) if operation_id == "the_district" else Color(0.26,0.45,0.49))
 var frame := dark.lightened(0.18)
 for dx: float in [-3.0,0.0,3.0]:
  _box(Vector3(x+dx,4.08,z),Vector3(2.22,0.16,8.15),frame)
  _box(Vector3(x+dx,7.0,z),Vector3(2.22,0.20,8.15),frame)
  for y: float in [4.85,6.15]:
   _box(Vector3(x+dx,y,z+4.065),Vector3(1.58,1.0,0.08),upper_glass)
   for side: float in [-1.0,1.0]:
    _box(Vector3(x+dx+side*0.84,y,z+4.11),Vector3(0.07,1.08,0.08),frame)
   _box(Vector3(x+dx,y-0.55,z+4.11),Vector3(1.74,0.08,0.12),wall.lightened(0.14))
   _box(Vector3(x+dx,y+0.55,z+4.11),Vector3(1.74,0.08,0.12),frame)
   _box(Vector3(x+dx,y,z+4.13),Vector3(0.055,0.98,0.10),frame)
  for side: float in [-1.0,1.0]:
   for bay_z: float in [-2.8,0.0,2.8]:
    _box(Vector3(x+side*5.11,5.55,z+bay_z),Vector3(0.08,1.45,1.52),upper_glass)
    _box(Vector3(x+side*5.17,5.55,z+bay_z-0.81),Vector3(0.10,1.55,0.07),frame)
    _box(Vector3(x+side*5.17,5.55,z+bay_z+0.81),Vector3(0.10,1.55,0.07),frame)
    _box(Vector3(x+side*5.18,4.76,z+bay_z),Vector3(0.14,0.08,1.66),wall.lightened(0.12))
  # A pair of vertical rain leaders and a roof coping finish the block silhouette.
  for side: float in [-1.0,1.0]:
   _box(Vector3(x+side*4.78,5.5,z+4.18),Vector3(0.10,3.0,0.10),frame)
  _box(Vector3(x,7.16,z+4.02),Vector3(10.15,0.18,0.35),wall.lightened(0.10))
  _box(Vector3(x-4.45,5.0,z-3.0),Vector3(0.72,0.42,0.56),dark)
  for vent: float in [-0.12,0.0,0.12]:
   _box(Vector3(x-4.83,5.0,z-3.0+vent),Vector3(0.04,0.28,0.045),wall.lightened(0.12))
 # Roof plant and exposed wet services are placed on the building's actual
 # service elevations. The risers terminate at a lockable street-level access
 # panel and remain outside storefront openings and the public route.
 for side: float in [-1.0,1.0]:
  var service_stack := Node3D.new()
  service_stack.name = "DistrictFacadeServiceStack"
  service_stack.position = Vector3(x+side*4.92,0.12,z+4.18)
  service_stack.rotation.y = PI*0.5 if side > 0.0 else -PI*0.5
  add_child(service_stack)
  CONSTRUCTION.service_riser(service_stack,"DistrictWetServiceRiser",Vector3.ZERO,3.58,Color(0.63,0.58,0.46),dark,3)
  CONSTRUCTION.box(service_stack,"DistrictServiceConduit",Vector3(0.34,3.82,0.14),Vector3(0.12,0.12,8.6),dark.lightened(0.12),0.52)
  CONSTRUCTION.box(service_stack,"DistrictServiceIsolationValve",Vector3(0.13,0.52,0.30),Vector3(0.26,0.32,0.20),accent,0.52)
 var roof_plant := _box(Vector3(x-3.65,7.62,z-2.6),Vector3(1.35,0.68,1.4),dark,true)
 roof_plant.name = "DistrictRooftopAirHandlingUnit"
 _box(Vector3(x-3.65,7.62,z-3.32),Vector3(0.92,0.36,0.04),Color(0.25,0.35,0.36))
 for vent: int in range(5):
  _box(Vector3(x-4.05+float(vent)*0.20,7.62,z-3.35),Vector3(0.035,0.28,0.025),wall.lightened(0.18))
 var room_region := NavigationRegion3D.new()
 room_region.position = Vector3(x,0.05,z)
 var room_nav := NavigationMesh.new()
 room_nav.vertices = PackedVector3Array([Vector3(-4.5,0,-4.0),Vector3(4.5,0,-4.0),Vector3(4.5,0,4.0),Vector3(-4.5,0,4.0)])
 room_nav.add_polygon(PackedInt32Array([0,3,2,1]))
 room_region.navigation_mesh = room_nav
 add_child(room_region)
 _sign("TEA / MARKET" if operation_id == "the_streets" else ("OFFICE / RECORDS" if operation_id == "the_district" else "PIER / SERVICES"),Vector3(x,2.7,z+4.86))

func _build_storefront_wall(x: float, z: float, side: float, wall: Color, accent: Color, dark: Color) -> void:
 var facade_x := x+side*5.0
 # Solid plinth and transom leave two real glazed shop bays and a clear entry.
 _box(Vector3(facade_x,0.32,z),Vector3(0.20,0.64,10.0),wall,true)
 _box(Vector3(facade_x,3.22,z),Vector3(0.20,1.16,10.0),wall,true)
 for pier_z: float in [-4.4,4.4]: _box(Vector3(facade_x,1.82,z+pier_z),Vector3(0.20,2.36,1.2),wall,true)
 for pier_z: float in [-1.25,1.25]: _box(Vector3(facade_x,1.82,z+pier_z),Vector3(0.20,2.36,0.50),wall,true)
 # The windows occupy actual holes in the shell: opaque facades no longer mask
 # the interior fitout, and the doorway is a continuous walk-through opening.
 var glass_tint := Color(0.20,0.46,0.50,0.30) if operation_id == "the_streets" else (Color(0.29,0.56,0.61,0.30) if operation_id == "the_district" else Color(0.34,0.60,0.65,0.30))
 for bay_z: float in [-2.65,2.65]:
  _glass(Vector3(facade_x-side*0.015,1.82,z+bay_z),Vector3(0.055,2.22,2.20),glass_tint)
  for jamb: float in [-1.18,1.18]: _box(Vector3(facade_x-side*0.10,1.82,z+bay_z+jamb),Vector3(0.10,2.32,0.08),dark)
  _box(Vector3(facade_x-side*0.10,0.67,z+bay_z),Vector3(0.14,0.10,2.42),wall.lightened(0.18))
  _box(Vector3(facade_x-side*0.10,2.98,z+bay_z),Vector3(0.12,0.10,2.42),dark)
  _box(Vector3(facade_x-side*0.11,1.82,z+bay_z),Vector3(0.10,2.18,0.06),dark)
 # A deep reveal, header, practical and two non-colliding leaves say “open”.
 for jamb_z: float in [-1.0,1.0]: _box(Vector3(facade_x-side*0.12,1.28,z+jamb_z),Vector3(0.16,2.56,0.14),accent.lightened(0.12))
 _box(Vector3(facade_x-side*0.12,2.58,z),Vector3(0.18,0.16,2.12),accent.lightened(0.12))
 for hinge: float in [-1.0,1.0]:
  var leaf := _box(Vector3(facade_x-side*0.48,1.15,z+hinge*0.50),Vector3(0.08,2.28,0.92),wall.darkened(0.14))
  leaf.name = "StorefrontDoorLeaf"
  leaf.add_to_group("district_storefront_door_leaf")
  leaf.rotation.y = side*PI*0.5
  _box(Vector3(facade_x-side*0.54,1.18,z+hinge*0.08),Vector3(0.035,0.14,0.035),Color(0.78,0.63,0.36))
 var threshold := _box(Vector3(facade_x,0.06,z),Vector3(0.65,0.12,2.25),paving_color(operation_id),false)
 threshold.name = "StorefrontThreshold"
 # A cantilever canopy, fascia, brackets and evenly spaced supports are tied
 # back to the building, rather than floating coloured rectangles.
 var canopy_color := accent if operation_id != "the_district" else Color(0.20,0.35,0.38)
 _box(Vector3(facade_x+side*0.58,3.56,z),Vector3(1.55,0.18,6.65),canopy_color)
 _box(Vector3(facade_x+side*1.34,3.31,z),Vector3(0.12,0.42,6.65),dark)
 for brace_z: float in [-2.9,2.9]:
  _box(Vector3(facade_x+side*0.50,3.12,z+brace_z),Vector3(0.10,0.74,0.10),dark)
  _box(Vector3(facade_x+side*0.36,2.96,z+brace_z),Vector3(0.44,0.08,0.10),dark)
 # Recessed display plinths make the rooms legible from street level.
 for bay_z: float in [-2.65,2.65]:
  _box(Vector3(x+side*3.80,0.76,z+bay_z),Vector3(1.50,1.48,1.72),dark.lightened(0.05),true)
  _box(Vector3(x+side*3.78,1.56,z+bay_z),Vector3(1.40,0.08,1.58),wall.lightened(0.17))
  if operation_id == "the_streets":
   for item: float in [-0.46,0.0,0.46]:
    _box(Vector3(x+side*3.74,1.79,z+bay_z+item),Vector3(0.44,0.30,0.34),Color(0.64,0.43,0.22) if item != 0.0 else Color(0.40,0.55,0.29))
    _box(Vector3(x+side*3.74,1.96,z+bay_z+item),Vector3(0.42,0.04,0.32),Color(0.76,0.62,0.39))
  elif operation_id == "the_district":
   _box(Vector3(x+side*3.74,1.82,z+bay_z),Vector3(0.72,0.42,0.54),Color(0.18,0.29,0.31))
   _box(Vector3(x+side*3.74,2.06,z+bay_z-0.02),Vector3(0.52,0.22,0.04),Color(0.21,0.70,0.67))
   _box(Vector3(x+side*3.74,2.23,z+bay_z),Vector3(0.22,0.10,0.20),Color(0.70,0.63,0.47))
  else:
   _box(Vector3(x+side*3.74,1.80,z+bay_z),Vector3(0.66,0.46,0.52),Color(0.69,0.57,0.37))
   _box(Vector3(x+side*3.74,2.10,z+bay_z),Vector3(0.50,0.10,0.10),Color(0.85,0.78,0.58))
   _box(Vector3(x+side*3.74,2.40,z+bay_z),Vector3(0.18,0.48,0.18),Color(0.76,0.25,0.15))
 # Differentiated mounted trade signs and an address-level lightbox.
 var store_label := "JADE LEAF  /  TEA & HERBS" if operation_id == "the_streets" else ("MERIDIAN  /  FINANCE DESK" if operation_id == "the_district" else "QUAY  /  FERRY SERVICES")
 _box(Vector3(facade_x+side*0.18,3.02,z),Vector3(0.16,0.48,4.8),dark)
 var fascia_light := _box(Vector3(facade_x+side*0.275,3.02,z),Vector3(0.035,0.30,4.4),accent)
 (fascia_light.get_child(0) as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var sign := Label3D.new()
 sign.name = "StorefrontTradeSign"
 sign.add_to_group("district_storefront_sign")
 sign.text = store_label
 sign.position = Vector3(facade_x+side*0.32,3.05,z)
 sign.rotation.y = -side*PI*0.5
 sign.font_size = 22
 sign.pixel_size = 0.004
 sign.modulate = Color(0.96,0.87,0.68)
 add_child(sign)
 # A shallow return, downpipe and reachable utility isolator finish the
 # façade junction and service lane without blocking either pedestrian line.
 for run_y: float in [0.48,3.0]: _box(Vector3(facade_x-side*0.13,run_y,z+4.9),Vector3(0.22,0.10,0.20),wall.darkened(0.08))
 _box(Vector3(facade_x+side*0.10,1.75,z+4.72),Vector3(0.10,3.3,0.10),dark)
 _box(Vector3(facade_x+side*0.23,1.35,z+4.55),Vector3(0.12,0.52,0.28),accent)

func _glass(pos: Vector3, size: Vector3, tint: Color) -> void:
 var holder := _box(pos,size,tint)
 holder.name = "StorefrontGlazing"
 holder.add_to_group("district_storefront_glazing")
 var glass := StandardMaterial3D.new()
 glass.albedo_color = tint
 glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 glass.roughness = 0.24
 glass.metallic = 0.12
 glass.cull_mode = BaseMaterial3D.CULL_DISABLED
 (holder.get_child(0) as MeshInstance3D).material_override = glass

func paving_color(operation: String) -> Color:
 if operation == "the_streets": return Color(0.39,0.37,0.34)
 if operation == "the_district": return Color(0.36,0.40,0.40)
 return Color(0.33,0.40,0.41)

func intel_world_position() -> Vector3:
 return to_global(intel_position)

func uniform_world_position() -> Vector3:
 return to_global(uniform_position)

func contains_world_position(point: Vector3) -> bool:
 var local := to_local(point)
 return absf(local.x) < 34.0 and local.z >= 0.0 and local.z < 69.0 and local.y > -1.0 and local.y < 8.0

func _process(delta: float) -> void:
 if beacon and beacon.visible:
  beacon_clock += delta
  beacon.light_energy = 0.30 + 0.08 * sin(beacon_clock * 1.4)
