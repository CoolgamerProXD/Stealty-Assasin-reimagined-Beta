extends Node3D
## Exploratory, fictional station blockout. This is not a campaign mission.
const CONSTRUCTION := preload("res://scripts/world/construction_kit.gd")
var player: HotelPlayer
var npcs: Array[HotelNpc] = []
var robber: HotelNpc
var operative: HotelNpc
var hud: Label
var access_zones: Array[Dictionary] = []
var message: String = "SCOUTING PREVIEW  /  Approach the two distinctive people. Escape returns to the menu."
var materials: Dictionary = {}
var meshes: Dictionary = {}

func _ready() -> void:
 _environment()
 _start_ambience("station")
 _station()
 player = HotelPlayer.new()
 player.position = Vector3(-19, 0.05, 4)
 add_child(player)
 player.mouse_sensitivity = float(Campaign.settings["sensitivity"])
 player.interaction_requested.connect(_interact)
 _population()
 var canvas := CanvasLayer.new()
 add_child(canvas)
 hud = Label.new()
 hud.position = Vector2(24, 20)
 hud.custom_minimum_size = Vector2(750, 0)
 hud.add_theme_font_size_override("font_size", 20)
 hud.add_theme_color_override("font_shadow_color", Color.BLACK)
 hud.add_theme_constant_override("shadow_offset_x", 2)
 hud.add_theme_constant_override("shadow_offset_y", 2)
 canvas.add_child(hud)

func _start_ambience(kind: String) -> void:
 var ambience := AudioStreamPlayer.new()
 ambience.bus = "Ambient"
 ambience.name = "LocationAmbience"
 ambience.stream = ProceduralSound.ambience(kind)
 add_child(ambience)
 ambience.play()

# Campaign instances may designate a small authored restricted zone. The
# independent exploration previews remain public and keep their old behavior.
func player_access_area(point: Vector3) -> String:
 for zone: Dictionary in access_zones:
  var rect: Variant = zone.get("rect")
  var floor_min := float(zone.get("floor_min", -100.0))
  var floor_max := float(zone.get("floor_max", 100.0))
  if rect is Rect2 and rect.has_point(Vector2(point.x,point.z)) and point.y >= floor_min and point.y <= floor_max:
   return str(zone.get("area","staff"))
 if has_meta("restricted_rect"):
  var area: Variant = get_meta("restricted_rect")
  if area is Rect2 and area.has_point(Vector2(point.x, point.z)): return "staff"
 return "public"

func permitted_exit(point: Vector3) -> Vector3:
 for zone: Dictionary in access_zones:
  var rect: Variant = zone.get("rect")
  if rect is Rect2 and rect.has_point(Vector2(point.x,point.z)) and point.y >= float(zone.get("floor_min",-100.0)) and point.y <= float(zone.get("floor_max",100.0)):
   var center: Vector2 = rect.get_center()
   return Vector3(center.x,point.y,center.y)
 if not has_meta("restricted_rect"): return point
 var area: Variant = get_meta("restricted_rect")
 if not area is Rect2: return point
 var options: Array[Vector3] = [Vector3(area.position.x - 0.8,point.y,point.z), Vector3(area.end.x + 0.8,point.y,point.z), Vector3(point.x,point.y,area.position.y - 0.8), Vector3(point.x,point.y,area.end.y + 0.8)]
 var best := options[0]
 for candidate: Vector3 in options:
  if candidate.distance_squared_to(point) < best.distance_squared_to(point): best = candidate
 return best

func footstep_surface(_point: Vector3) -> String:
 return "stone"

func _environment() -> void:
 var station_scene: bool = get_script().resource_path == "res://scripts/world/tung_chung_preview.gd"
 var operation := str(get_meta("operation_id", ""))
 var station_mood: bool = station_scene or operation == "tung_chung"
 var env := WorldEnvironment.new()
 var data := Environment.new()
 data.background_mode = Environment.BG_COLOR
 data.background_color = Color(0.025, 0.045, 0.055) if station_mood else Color(0.11, 0.17, 0.22)
 data.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 data.ambient_light_color = Color(0.62, 0.69, 0.71) if station_mood else Color(0.75, 0.82, 0.85)
 # Retain the night-cool palette while lifting station shadow detail so public
 # circulation, furniture and characters remain legible in the darker scene.
 data.ambient_light_energy = 1.0 if station_mood else 0.9
 data.adjustment_enabled = station_mood
 data.adjustment_contrast = 1.0 if station_mood else 1.0
 data.adjustment_saturation = 0.96 if station_mood else 1.0
 env.environment = data
 add_child(env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-48, -25, 0)
 sun.light_color = Color(0.66, 0.76, 0.80) if station_mood else Color.WHITE
 sun.light_energy = 0.48 if station_mood else 0.85
 if operation == "the_streets":
  sun.light_color = Color(1.0,0.82,0.68)
 elif operation == "the_district":
  sun.light_color = Color(0.84,0.92,1.0)
 elif operation == "the_harbour":
  sun.light_color = Color(0.70,0.84,1.0)
  sun.light_energy = 0.75
 elif operation == "hong_kong_sandbox":
  # Clear late-day light keeps the connected skyline readable across districts.
  sun.light_color = Color(1.0,0.88,0.72)
  sun.light_energy = 0.92
 elif operation == "ngong_ping":
  sun.light_color = Color(1.0,0.91,0.75)
  # The fictional buried facility has no directional daylight; give the
  # Ngong Ping scene a restrained warm ambient floor so matte interiors remain
  # readable between ceiling practical pools.
  data.ambient_light_color = Color(0.80,0.82,0.78)
  data.ambient_light_energy = 1.25
 sun.shadow_enabled = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["shadows"])
 sun.add_to_group("quality_lights")
 add_child(sun)
 var nav := NavigationRegion3D.new()
 var mesh := NavigationMesh.new()
 if get_script().resource_path == "res://scripts/world/tung_chung_preview.gd":
  mesh = _station_navigation_mesh()
 else:
  # Landscape studies have different geometry and keep their own local routes.
  mesh.vertices = PackedVector3Array([Vector3(-21,0,-13), Vector3(21,0,-13), Vector3(21,0,13), Vector3(-21,0,13)])
  mesh.add_polygon(PackedInt32Array([0,3,2,1]))
 nav.navigation_mesh = mesh
 add_child(nav)

# Authored navigation holes expand the solid columns and information island by
# the NPC capsule's radius. The polygons share vertices; routes can turn around
# the obstacles rather than walking through a broad, unbaked rectangle.
func _station_navigation_mesh() -> NavigationMesh:
 var xs: Array[float] = [-21.0,-3.9,1.9,21.0]
 var zs: Array[float] = [-13.0,-6.7,-5.3,-1.4,1.4,5.3,6.7,11.1]
 var obstacles: Array[Rect2] = [Rect2(-3.9,-1.4,5.8,2.8)]
 for x: float in [-18.0,-10.0,-2.0,6.0,14.0]:
  xs.append(x-0.7)
  xs.append(x+0.7)
  for z: float in [-6.0,6.0]: obstacles.append(Rect2(x-0.7,z-0.7,1.4,1.4))
 xs.sort()
 zs.sort()
 var vertices := PackedVector3Array()
 for z: float in zs:
  for x: float in xs: vertices.append(Vector3(x,0,z))
 var mesh := NavigationMesh.new()
 mesh.vertices = vertices
 for row: int in range(zs.size()-1):
  for column: int in range(xs.size()-1):
   var middle := Vector2((xs[column]+xs[column+1])*0.5,(zs[row]+zs[row+1])*0.5)
   var blocked := false
   for obstacle: Rect2 in obstacles:
    if obstacle.has_point(middle):
     blocked = true
     break
   if not blocked:
    var a: int = row*xs.size()+column
    mesh.add_polygon(PackedInt32Array([a,a+xs.size(),a+xs.size()+1,a+1]))
 return mesh

func _box(pos: Vector3, size: Vector3, color: Color, solid: bool = false, finish: String = "plain") -> Node3D:
 var holder: Node3D = StaticBody3D.new() if solid else Node3D.new()
 holder.position = pos
 add_child(holder)
 var part := MeshInstance3D.new()
 if not meshes.has(size): meshes[size] = StationMaterials.box_mesh(size)
 part.mesh = meshes[size]
 var material_key := finish + ":" + color.to_html(true)
 if not materials.has(material_key): materials[material_key] = StationMaterials.material(color, finish)
 part.material_override = materials[material_key]
 holder.add_child(part)
 if solid:
  var collider := CollisionShape3D.new()
  var shape := BoxShape3D.new()
  shape.size = size
  collider.shape = shape
  holder.add_child(collider)
 return holder

func _sign(text: String, pos: Vector3, size: int = 38) -> void:
 var label := Label3D.new()
 label.text = text
 label.position = pos
 label.font_size = size
 label.pixel_size = 0.004
 label.modulate = Color(0.94, 0.95, 0.9)
 label.no_depth_test = false
 add_child(label)

func _station() -> void:
 var floor_color := Color(0.51, 0.56, 0.55)
 var wall := Color(0.58, 0.64, 0.65)
 var dark := Color(0.15, 0.22, 0.25)
 var orange := Color(0.88, 0.49, 0.19)
 _box(Vector3(0,-0.2,0), Vector3(44,0.4,28), floor_color, true, "terrazzo")
 _box(Vector3(0,5.3,0), Vector3(44,0.25,28), Color(0.43,0.48,0.47), false, "concrete")
 _box(Vector3(-22,2.6,0), Vector3(0.3,5.2,28), wall, true, "tile")
 _box(Vector3(22,2.6,0), Vector3(0.3,5.2,28), wall, true, "tile")
 _station_retail_arcade(wall, dark, orange)
 if str(get_meta("operation_id", "")) == "tung_chung":
  # Fictional platform doorway aligns with the playable carriage aisle.
  _box(Vector3(-2.5,2.6,14), Vector3(39,5.2,0.3), wall, true, "tile")
  _box(Vector3(21.5,2.6,14), Vector3(1,5.2,0.3), wall, true, "tile")
 else: _box(Vector3(0,2.6,14), Vector3(44,5.2,0.3), wall, true, "tile")
 # Rhythm of columns, floor strips and ceiling lights establishes the concourse.
 for x: float in [-18.0,-10.0,-2.0,6.0,14.0]:
  for z: float in [-6.0,6.0]:
   _box(Vector3(x,2.6,z), Vector3(0.6,5.2,0.6), Color(0.56,0.62,0.62), true, "concrete")
   _box(Vector3(x,0.35,z), Vector3(0.8,0.7,0.8), dark, false, "brushed_metal")
  _box(Vector3(x,5.1,0), Vector3(4.8,0.05,0.3), Color(0.82,0.72,0.55), false, "emissive")
 for x: float in [-14.0,-7.0,0.0,7.0,14.0]:
  _box(Vector3(x,0.015,0), Vector3(0.04,0.03,26), Color(0.40,0.46,0.46))
 _box(Vector3(-15,1.1,-11.5), Vector3(8,2.2,2), dark, false, "painted_metal")
 _box(Vector3(-15,1.35,-10.45), Vector3(7.5,0.12,0.12), orange, false, "emissive")
 _sign("TICKETS  /  CUSTOMER SERVICE", Vector3(-15,2.65,-10.35), 32)
 for x: float in [-19.0,-17.5,-16.0,-14.5]:
  _box(Vector3(x,0.6,-8.5), Vector3(0.75,1.2,0.55), Color(0.24,0.35,0.37), true, "painted_metal")
  _box(Vector3(x,1.23,-8.5), Vector3(0.6,0.07,0.45), orange, false, "emissive")
 # Fictional concourse stairway and upper landing; no railway access.
 _box(Vector3(17,3.125,-6), Vector3(8,0.35,4), Color(0.39,0.47,0.47), true, "painted_metal")
 _station_stair_collision()
 _box(Vector3(17,3.9,-3.95), Vector3(8,1.1,0.12), Color(0.31,0.47,0.49), false, "brushed_metal")
 for i: int in range(16):
  _box(Vector3(14.5, float(i)*0.22+0.04, 3.5-float(i)*0.47), Vector3(2.4,0.12,0.48), Color(0.42,0.49,0.48), false, "terrazzo")
  _box(Vector3(13.25,float(i)*0.22+0.7,3.5-float(i)*0.47), Vector3(0.08,0.12,0.48), dark, false, "brushed_metal")
  _box(Vector3(15.75,float(i)*0.22+0.7,3.5-float(i)*0.47), Vector3(0.08,0.12,0.48), dark, false, "brushed_metal")
 _sign("CONCOURSE  /  UPPER WALKWAY", Vector3(17,4.65,-3.85), 28)
 # The information island is solid; seating remains decorative.
 _box(Vector3(-1,0.55,0), Vector3(5,1.1,2), Color(0.26,0.36,0.38), true, "painted_metal")
 _box(Vector3(-1,1.15,0), Vector3(5.2,0.12,2.2), Color(0.72,0.71,0.63), false, "terrazzo")
 _box(Vector3(-1,2.05,0.12), Vector3(3.0,0.9,0.06), Color(0.24,0.58,0.61), false, "glass")
 _sign("INFORMATION", Vector3(-1,2.6,0.5), 36)
 for x: float in [5.0,9.0,13.0]:
  _box(Vector3(x,0.5,5), Vector3(2.7,0.15,0.8), Color(0.25,0.20,0.16), false, "wood")
  _box(Vector3(x,0.8,5.4), Vector3(2.7,0.65,0.12), Color(0.31,0.39,0.38), false, "fabric")
  for side: float in [-0.9,0.9]: _box(Vector3(x+side,0.22,5), Vector3(0.12,0.5,0.55), dark, false, "brushed_metal")
 # Fictional platform edge and stationary train facade; no rail-access mechanics.
 _box(Vector3(0,0.025,10.7), Vector3(43,0.05,0.25), Color(0.94,0.66,0.20), false, "emissive")
 var campaign_train := str(get_meta("operation_id", "")) == "tung_chung"
 if campaign_train:
  _box(Vector3(-1.25,1.7,12.6), Vector3(35.5,3.4,1.3), Color(0.61,0.69,0.68), true, "painted_metal")
  _box(Vector3(-1.25,1.8,11.92), Vector3(35.0,1.0,0.05), dark, false, "glass")
 else:
  _box(Vector3(0,1.7,12.6), Vector3(38,3.4,1.3), Color(0.61,0.69,0.68), true, "painted_metal")
  _box(Vector3(0,1.8,11.92), Vector3(37,1.0,0.05), dark, false, "glass")
 if campaign_train:
  # Continuous silver body with a dark glazed band and restrained red/teal
  # livery. The platform-side glass doors sit in front of the train body.
  _box(Vector3(-1.25,0.72,11.91),Vector3(35.0,0.10,0.045),Color(0.78,0.27,0.20),false,"emissive")
  _box(Vector3(-1.25,1.04,11.91),Vector3(35.0,0.075,0.045),Color(0.22,0.58,0.62),false,"emissive")
 for x: float in [-14.0,-10.0,-6.0,-2.0,2.0,6.0,10.0,14.0]:
  # Sliding platform-screen door pair, stainless jambs, safety threshold and
  # two subtle amber door markers. Horizontal floor/track alignment stays fixed.
  _box(Vector3(x,1.78,11.56),Vector3(2.55,1.70,0.055),Color(0.34,0.54,0.57,0.46),false,"glass")
  for side: float in [-1.0,0.0,1.0]:
   _box(
    Vector3(x + side * 1.30, 1.78, 11.52),
    Vector3(0.075, 1.82, 0.10),
    Color(0.63, 0.69, 0.66),
    false,
    "brushed_metal"
   )
  _box(Vector3(x,0.90,11.50),Vector3(2.72,0.11,0.13),Color(0.30,0.37,0.37),false,"brushed_metal")
  _box(Vector3(x,0.97,11.43),Vector3(1.00,0.035,0.025),Color(0.94,0.62,0.24),false,"emissive")
  for side: float in [-1.0,1.0]:
   _box(
    Vector3(x + side * 0.78, 2.42, 11.50),
    Vector3(0.07, 0.20, 0.025),
    Color(0.92, 0.60, 0.23),
    false,
    "emissive"
   )
 _box(Vector3(-1.25 if campaign_train else 0,0.65,11.9), Vector3(35.5 if campaign_train else 38,0.12,0.06), orange)
 _box(Vector3(1,4.2,8), Vector3(9,0.8,0.2), dark)
 _sign("PLATFORM  /  TRAINS", Vector3(1,4.2,7.86), 40)
 # Non-operational architectural details; routes are not real station layouts.
 for x: float in [-18.0,-10.0,-2.0,6.0,14.0]:
  _box(Vector3(x,5.12,-4), Vector3(0.24,0.18,17), Color(0.25,0.31,0.31))
  _box(Vector3(x,3.0,-13.82), Vector3(5.0,0.05,0.05), orange)
  _box(Vector3(x,0.08,0), Vector3(0.04,0.04,19), Color(0.64,0.68,0.64))
 for x: float in [-9.0,-5.0,2.0,6.0,9.0,13.0]:
  _box(Vector3(x,2.4,-11.34),Vector3(1.1,0.58,0.025),Color(0.84,0.72,0.50))
  _box(Vector3(x,2.4,-11.30),Vector3(0.96,0.44,0.02),Color(0.26,0.39,0.37))
 for x: float in [-17.0,-9.0,-1.0,7.0,15.0]:
  _box(Vector3(x,1.0,11.83),Vector3(0.035,1.9,0.035),Color(0.92,0.65,0.27),false,"emissive")
  _box(Vector3(x,2.9,11.83),Vector3(0.8,0.10,0.035),Color(0.92,0.65,0.27),false,"emissive")
 _station_architecture()
 _station_lighting()
 _station_service_installations()

func _station_retail_arcade(wall: Color, dark: Color, orange: Color) -> void:
 # Extend the paid concourse into three real, accessible retail rooms rather
 # than dressing the old north wall with shallow display boxes.
 _box(Vector3(0,-0.2,-21.0),Vector3(44,0.4,14.4),Color(0.47,0.52,0.51),true,"terrazzo")
 _box(Vector3(0,5.3,-21.0),Vector3(44,0.25,14.4),Color(0.31,0.37,0.37),false,"concrete")
 for side: float in [-1.0,1.0]:
  _box(Vector3(side*22.0,2.6,-21.0),Vector3(0.3,5.2,14.4),wall,true,"tile")
 _box(Vector3(0,2.6,-28.15),Vector3(44,5.2,0.3),wall,true,"tile")
 # Four masonry piers separate three 2.8 m portals; the short headers and
 # deep reveals carry the existing tiled station wall into the arcade.
 for span: Vector2 in [Vector2(-22.0,-4.4),Vector2(-1.6,2.4),Vector2(5.6,9.4),Vector2(12.6,22.0)]:
  _box(Vector3((span.x+span.y)*0.5,2.6,-14.0),Vector3(span.y-span.x,5.2,0.3),wall,true,"tile")
 for index: int in range(3):
  var x := [-3.0,4.0,11.0][index]
  var room_dark := Color(0.21,0.29,0.30)
  var frame := Color(0.60,0.66,0.63)
  for side: float in [-1.0,1.0]:
   _box(Vector3(x+side*3.0,2.6,-21.0),Vector3(0.18,5.2,14.0),wall.darkened(0.08),true,"tile")
   _box(Vector3(x+side*1.48,4.28,-14.0),Vector3(0.16,1.84,0.32),room_dark,false,"painted_metal")
   var open_leaf := _box(Vector3(x+side*1.82,1.32,-14.28),Vector3(0.82,2.64,0.075),Color(0.31,0.40,0.41),false,"brushed_metal")
   open_leaf.rotation.y = PI*0.5
   _box(Vector3(x+side*1.90,1.30,-14.34),Vector3(0.04,0.16,0.035),orange,false,"brushed_metal")
  # Glass transoms, an overhead wayfinding fascia and a flush threshold make
  # each opening read as a maintained shopfront, not an unfinished wall hole.
  var transom := CONSTRUCTION.box(self,"RetailArcadeTransom",Vector3(x,3.56,-13.80),Vector3(2.82,0.46,0.055),Color(0.22,0.39,0.42,0.45),0.2)
  transom.name = "RetailArcadeTransom_%02d" % index
  _box(Vector3(x,0.045,-14.1),Vector3(2.75,0.09,0.72),Color(0.66,0.56,0.39),false,"terrazzo")
  _box(Vector3(x,4.16,-13.78),Vector3(3.05,0.16,0.16),Color(0.16,0.24,0.26),false,"painted_metal")
  var shop_name := ["PAPER & PRESS","TEA HOUSE","MARKET PROVISIONS"][index]
  _sign(shop_name,Vector3(x,4.16,-13.66),29)
  _box(Vector3(x,0.04,-21.0),Vector3(5.55,0.035,12.7),Color(0.48,0.52,0.48),false,"terrazzo")
  _box(Vector3(x,4.92,-21.0),Vector3(5.5,0.08,0.20),Color(0.18,0.26,0.27),false,"painted_metal")
  if index == 0:
   # Paper and press: archive-grade shelving, a returns counter and compact
   # periodical racks with a central customer aisle.
   for side: float in [-1.0,1.0]:
    _box(Vector3(x+side*2.35,1.72,-21.5),Vector3(0.42,3.25,8.4),room_dark,false,"painted_metal")
    for shelf_y: float in [0.72,1.38,2.04,2.70]: _box(Vector3(x+side*2.08,shelf_y,-21.5),Vector3(0.16,0.08,7.7),Color(0.62,0.51,0.36),false,"wood")
    for dz: float in [-3.7,-2.5,-1.3,-0.1,1.1,2.3,3.5]: _box(Vector3(x+side*1.92,1.02,-21.5+dz),Vector3(0.20,0.46,0.64),Color(0.48,0.29,0.20) if int(absf(dz*10.0))%2==0 else Color(0.22,0.42,0.43),false,"fabric")
   _box(Vector3(x,0.92,-18.2),Vector3(3.8,1.82,0.82),Color(0.29,0.23,0.18),true,"wood")
   _box(Vector3(x,1.88,-18.2),Vector3(4.0,0.10,0.92),Color(0.58,0.48,0.35),false,"wood")
   for dx: float in [-1.2,0.0,1.2]: _box(Vector3(x+dx,1.98,-18.2),Vector3(0.48,0.055,0.36),Color(0.71,0.58,0.39),false,"fabric")
  elif index == 1:
   # Tea house: service bar, brewing counter, back-bar shelving and a two-seat
   # tasting ledge. The wide central aisle stays clear from portal to stockroom.
   _box(Vector3(x+1.95,0.82,-20.6),Vector3(1.15,1.64,8.8),room_dark,true,"painted_metal")
   _box(Vector3(x+1.90,1.68,-20.6),Vector3(1.35,0.14,9.0),Color(0.60,0.47,0.32),false,"wood")
   _box(Vector3(x+1.30,1.74,-20.2),Vector3(0.12,0.38,0.34),Color(0.72,0.55,0.32),false,"brushed_metal")
   for dz: float in [-3.3,-1.1,1.1,3.3]:
    _box(Vector3(x-1.9,2.05,-21.0+dz),Vector3(1.55,2.65,0.16),Color(0.27,0.34,0.33),false,"wood")
    for shelf_y: float in [1.15,1.95,2.75]: _box(Vector3(x-1.9,shelf_y,-20.86+dz),Vector3(1.45,0.08,0.10),Color(0.70,0.56,0.34),false,"wood")
    _box(Vector3(x-1.9,1.40,-20.48+dz),Vector3(0.42,0.38,0.36),Color(0.64,0.47,0.26),false,"fabric")
   _box(Vector3(x-0.4,0.82,-17.7),Vector3(2.8,0.12,0.72),Color(0.38,0.26,0.18),false,"wood")
   for dx: float in [-1.0,1.0]: _box(Vector3(x-0.4+dx,0.44,-17.7),Vector3(0.10,0.76,0.10),room_dark,false,"brushed_metal")
  else:
   # Market provisions: chilled display cases, produce bins and a cleanable
   # packing bench tied back to the rear stock wall.
   for side: float in [-1.0,1.0]:
    _box(Vector3(x+side*2.05,1.14,-20.6),Vector3(1.12,2.25,7.2),Color(0.23,0.33,0.34),true,"painted_metal")
    for dz: float in [-2.4,-0.8,0.8,2.4]: _box(Vector3(x+side*2.02,2.33,-20.6+dz),Vector3(0.94,0.08,1.2),Color(0.65,0.58,0.42) if side < 0.0 else Color(0.44,0.57,0.35),false,"terrazzo")
   for dz: float in [-2.8,-0.8,1.2,3.2]:
    _box(Vector3(x,0.42,-21.0+dz),Vector3(1.55,0.78,1.35),Color(0.38,0.27,0.18),true,"wood")
    _box(Vector3(x,0.84,-21.0+dz),Vector3(1.42,0.10,1.20),Color(0.55,0.40,0.24),false,"wood")
  var practical := OmniLight3D.new()
  practical.name = "RetailArcadePractical_%02d" % index
  practical.position = Vector3(x,4.05,-21.0)
  practical.light_color = Color(1.0,0.79,0.57) if index == 1 else Color(0.82,0.91,0.90)
  practical.light_energy = 1.25
  practical.omni_range = 11.0
  practical.shadow_enabled = false
  practical.add_to_group("quality_practicals")
  practical.visible = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["practicals"])
  add_child(practical)
 # Ceiling beam and pipe trunk show the extension's actual service route.
 for z: float in [-17.0,-22.0,-27.0]:
  _box(Vector3(0,4.88,z),Vector3(41.0,0.16,0.24),Color(0.17,0.25,0.27),false,"painted_metal")
  for x: float in [-19.0,-9.0,1.0,11.0,19.0]: _box(Vector3(x,4.67,z),Vector3(0.10,0.42,0.10),Color(0.48,0.55,0.52),false,"brushed_metal")

func _station_service_installations() -> void:
 # Back-of-house infrastructure is grouped on the fixed service wall, while
 # passenger circulation, doors, and the existing navmesh remain untouched.
 CONSTRUCTION.service_riser(self,"StationElectricalRiser",Vector3(20.45,0.08,-12.95),4.55,Color(0.57,0.61,0.58),Color(0.17,0.24,0.26),4)
 for service_x: float in [-20.5,20.5]:
  var cabinet := CONSTRUCTION.box(self,"StationFireEquipmentCabinet",Vector3(service_x,1.22,-13.66),Vector3(0.82,1.48,0.30),Color(0.57,0.20,0.15),0.7)
  cabinet.set_meta("life_safety",true)
  CONSTRUCTION.box(self,"StationFireCabinetLabel",Vector3(service_x,1.53,-13.48),Vector3(0.34,0.14,0.035),Color(0.94,0.82,0.63),0.55,0.18)
  CONSTRUCTION.box(self,"StationFireCabinetHandle",Vector3(service_x+0.29,1.16,-13.46),Vector3(0.055,0.28,0.045),Color(0.76,0.69,0.51),0.45)
  CONSTRUCTION.box(self,"StationEmergencyLight",Vector3(service_x,2.38,-13.55),Vector3(0.56,0.18,0.12),Color(0.92,0.63,0.31),0.5,0.65)
 # Twin continuous cable trays run under the vault and terminate at the
 # station electrical riser, rather than appearing as floating trim.
 for tray_x: float in [-18.0,-10.0,-2.0,6.0,14.0]:
  CONSTRUCTION.trim_run(self,"StationCableTray",Vector3(tray_x,4.82,-12.1),Vector3(tray_x,4.82,10.8),0.12,Color(0.16,0.24,0.26))
  CONSTRUCTION.box(self,"StationTrayHanger",Vector3(tray_x,4.64,-12.0),Vector3(0.10,0.42,0.10),Color(0.33,0.41,0.41),0.5)
 # Platform drainage and a continuous tactile guidance band distinguish the
 # public edge from the clean through-route without adding collision hazards.
 CONSTRUCTION.box(self,"PlatformTactileField",Vector3(-1.0,0.025,9.02),Vector3(34.0,0.05,0.62),Color(0.74,0.55,0.28),0.94)
 for x: float in range(-17,17,1):
  CONSTRUCTION.box(self,"PlatformTactileBar",Vector3(float(x),0.058,9.02),Vector3(0.075,0.025,0.50),Color(0.88,0.70,0.39),0.86)
 for x: float in [-18.0,-10.0,-2.0,6.0,14.0]:
  CONSTRUCTION.box(self,"PlatformDrainGrille",Vector3(x,0.035,10.0),Vector3(1.5,0.04,0.16),Color(0.15,0.21,0.22),0.52)
  for slot: int in range(6):
   CONSTRUCTION.box(self,"PlatformDrainSlot",Vector3(x-0.57+float(slot)*0.23,0.058,10.0),Vector3(0.035,0.015,0.13),Color(0.48,0.54,0.50),0.48)

func _station_architecture() -> void:
 # Shallow barrel-vault ribs lift the ceiling rhythm above the concourse. One
 # MultiMesh batches every repeated segment into a single material/draw call.
 var rib_transforms: Array[Transform3D] = []
 for z: float in [-10.0,-1.0,8.0]:
  for i: int in range(24):
   var x0 := -20.0 + 40.0 * float(i) / 24.0
   var x1 := -20.0 + 40.0 * float(i + 1) / 24.0
   var y0 := 4.18 + 1.05 * sqrt(maxf(0.0, 1.0 - (x0 / 20.0) * (x0 / 20.0)))
   var y1 := 4.18 + 1.05 * sqrt(maxf(0.0, 1.0 - (x1 / 20.0) * (x1 / 20.0)))
   var delta := Vector2(x1 - x0, y1 - y0)
   var basis := Basis(Vector3(0,0,1),atan2(delta.y,delta.x)).scaled(Vector3(delta.length(),0.24,0.34))
   rib_transforms.append(Transform3D(basis,Vector3((x0+x1)*0.5,(y0+y1)*0.5,z)))
 var ribs := MultiMesh.new()
 ribs.transform_format = MultiMesh.TRANSFORM_3D
 ribs.mesh = StationMaterials.box_mesh(Vector3.ONE)
 ribs.instance_count = rib_transforms.size()
 for i: int in range(rib_transforms.size()): ribs.set_instance_transform(i,rib_transforms[i])
 var rib_mesh := MultiMeshInstance3D.new()
 rib_mesh.name = "VaultRibs"
 rib_mesh.multimesh = ribs
 rib_mesh.material_override = StationMaterials.material(Color(0.49,0.55,0.54),"concrete")
 rib_mesh.custom_aabb = AABB(Vector3(-21,3.7,-11),Vector3(42,1.8,21))
 add_child(rib_mesh)
 # Dark cable trays and narrow emissive wayfinding strips give the high ceiling
 # a believable service zone without filling it with extra point lights.
 for x: float in [-18.0,-10.0,-2.0,6.0,14.0]:
  _box(Vector3(x,4.86,0),Vector3(0.16,0.16,22),Color(0.14,0.22,0.24),false,"painted_metal")
 for z: float in [-11.0,-3.0,5.0,12.0]:
  _box(Vector3(20.85,2.2,z),Vector3(0.025,0.7,1.8),Color(0.33,0.45,0.46),false,"painted_metal")
  _box(Vector3(20.82,2.2,z-0.45),Vector3(0.018,0.36,0.62),Color(0.91,0.61,0.29),false,"emissive")
 # Ticket-control lanes: physical waist-high islands with broad, clear gaps.
 # The campaign path from deployment to courier stays on the west side.
 for x: float in [-6.0,-2.0,2.0,6.0]:
  _box(Vector3(x,0.43,-8.0),Vector3(1.35,0.86,0.95),Color(0.20,0.30,0.32),true,"brushed_metal")
  _box(Vector3(x,0.91,-8.0),Vector3(1.15,0.08,0.72),Color(0.63,0.67,0.62),false,"terrazzo")
  _box(Vector3(x,0.99,-8.0),Vector3(0.48,0.035,0.5),Color(0.90,0.57,0.23),false,"emissive")
  _box(Vector3(x-0.52,0.95,-8.38),Vector3(0.035,0.04,0.45),Color(0.54,0.68,0.62),false,"emissive")
 # Wall-mounted departure boards, framed poster cases, and a continuous tactile
 # strip make station functions legible without using copied real-world signs.
 _box(Vector3(0.0,4.25,-4.2),Vector3(8.5,0.9,0.22),Color(0.10,0.17,0.19),false,"painted_metal")
 _box(Vector3(0.0,4.28,-4.07),Vector3(7.7,0.54,0.035),Color(0.17,0.34,0.35),false,"emissive")
 _sign("TUNG CHUNG   ·   PLATFORM 01     /     SERVICE INTERRUPTED",Vector3(0,4.3,-4.03),24)
 for x: float in [-20.6,-16.8,-11.0,11.0]:
  var side := -13.78 if absf(x) > 16.0 else 13.78
  if side > 0.0 and str(get_meta("operation_id", "")) == "tung_chung" and absf(x) > 16.0:
   continue # Keep the walk-on train doorway completely clear.
  _box(Vector3(x,2.65,side),Vector3(2.0,2.3,0.04),Color(0.18,0.27,0.29),false,"brushed_metal")
  _box(Vector3(x,2.65,side-0.035 if side < 0.0 else side+0.035),Vector3(1.78,2.06,0.025),Color(0.48,0.36,0.27),false,"wood")
 # Amber tactile guidance and a rough dark boarding edge contrast the pale floor.
 _box(Vector3(-1.0,0.012,8.5),Vector3(34,0.024,0.16),Color(0.77,0.51,0.20),false,"rubber")
 _box(Vector3(0.0,-0.005,12.1),Vector3(42,0.045,0.55),Color(0.17,0.22,0.23),false,"rubber")
 # Signage brackets and a restrained red service light establish the operation's
 # own transit-noir accent; no logos, recognizable maps, or copied station marks.
 _box(Vector3(1.0,4.58,7.92),Vector3(8.9,0.08,0.42),Color(0.80,0.35,0.28),false,"emissive")
 _sign("EXIT  →     PLATFORM 01",Vector3(1,4.2,7.84),32)

func _station_lighting() -> void:
 # Low-cost practicals: one cool overhead rhythm and two warm service pools.
 # They never cast shadows; the existing directional light owns the shadow map.
 var lights: Array[Array] = [
  # Ceiling practicals overlap gently to avoid dark gaps across the public
  # concourse; no single broad ambient wash is used as a substitute.
  [Vector3(-15,4.55,-3),Color(1.0,0.78,0.60),1.55,13.0],
  [Vector3(-5,4.55,1),Color(0.72,0.88,0.91),1.60,13.0],
  [Vector3(5,4.55,-2),Color(0.78,0.90,0.91),1.60,13.0],
  [Vector3(15,4.55,1),Color(1.0,0.76,0.56),1.50,13.0],
  [Vector3(-10,4.55,9),Color(0.80,0.91,0.92),1.20,11.0],
  [Vector3(0,4.55,9),Color(0.82,0.91,0.92),1.20,11.0],
  [Vector3(10,4.55,9),Color(0.80,0.91,0.92),1.20,11.0],
  [Vector3(19.8,3.1,10),Color(0.50,0.76,0.82),0.90,9.0],
 ]
 for spec: Array in lights:
  var light := OmniLight3D.new()
  light.position = spec[0]
  light.light_color = spec[1]
  light.light_energy = float(spec[2])
  light.omni_range = float(spec[3])
  light.shadow_enabled = false
  light.add_to_group("quality_practicals")
  light.visible = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["practicals"])
  add_child(light)

# Invisible smooth collision follows the visible stair treads. The ends
# overlap the concourse and landing to avoid a capsule-catching vertical lip.
func _station_stair_collision() -> void:
 var ramp := StaticBody3D.new()
 ramp.name = "StationStairCollision"
 ramp.position = Vector3(14.5,1.64,-0.25)
 ramp.rotation.x = atan(3.45 / 7.5)
 add_child(ramp)
 var collider := CollisionShape3D.new()
 var box := BoxShape3D.new()
 box.size = Vector3(2.4,0.14,sqrt(3.45*3.45 + 7.5*7.5))
 collider.shape = box
 ramp.add_child(collider)

func _population() -> void:
 var coats: Array[Color] = [Color(0.55,0.31,0.24), Color(0.25,0.36,0.46), Color(0.42,0.44,0.30), Color(0.48,0.36,0.46), Color(0.28,0.45,0.42), Color(0.60,0.52,0.38), Color(0.31,0.32,0.35)]
 for i: int in range(14):
  var profile := NpcProfile.new()
  profile.identity = "Passenger %02d" % i
  profile.occupation = "employee" if i % 5 == 0 else "civilian"
  var start := Vector3(-17 + float(i % 7) * 5.5, 0.05, -3.0 + float(i / 7) * 11.5)
  # Keep adjacent local routines disjoint so passengers do not walk
  # directly into each other on the broad, unbaked station navmesh.
  var end := Vector3(clampf(start.x + (1.7 if i % 2 == 0 else -1.7), -19, 19), 0.05, start.z)
  profile.schedule.append(ScheduleEntry.new(end, "waiting" if i % 3 == 0 else "conversing", 3.0 + float(i % 4)))
  profile.schedule.append(ScheduleEntry.new(start, "idle", 2.0 + float(i % 3)))
  var npc := HotelNpc.new()
  npc.profile = profile
  npc.position = start
  add_child(npc)
  npc.person.clothing.albedo_color = coats[i % coats.size()]
  npcs.append(npc)
 robber = _target("Station suspect", "manager", Vector3(-12,0.05,-5), Vector3(-7,0.05,-5))
 operative = _target("Unidentified operative", "security", Vector3(10,0.05,-5), Vector3(15,0.05,-5))

func _target(identity: String, role: String, start: Vector3, end: Vector3) -> HotelNpc:
 var profile := NpcProfile.new()
 profile.identity = identity
 profile.occupation = role
 profile.schedule.append(ScheduleEntry.new(end, "waiting", 5.0))
 profile.schedule.append(ScheduleEntry.new(start, "idle", 4.0))
 var npc := HotelNpc.new()
 npc.profile = profile
 npc.position = start
 add_child(npc)
 npcs.append(npc)
 return npc

func _interact() -> void:
 if player.global_position.distance_to(robber.global_position) < 2.0:
  message = "SCOUTING  /  A sharply dressed suspect moves between ticketing and the concourse."
 elif player.global_position.distance_to(operative.global_position) < 2.0:
  message = "SCOUTING  /  A watchful operative keeps an eye on the platform."
 else:
  message = "SCOUTING PREVIEW  /  Approach either distinctive person and press E."

func _process(_delta: float) -> void:
 hud.text = "TUNG CHUNG  /  EARLY MAP PREVIEW\n" + message + "\nWASD MOVE   ·   E OBSERVE   ·   ESC RETURN"

func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("release_mouse"):
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  Campaign.return_to_maps = true
  get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
