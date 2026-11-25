extends "res://scripts/world/tung_chung_preview.gd"
## Original explorable landscape studies, separate from campaign progression.
const CONSTRUCTION := preload("res://scripts/world/construction_kit.gd")
@export_enum("city", "mountain") var preview_kind: String = "city"
var accents: Array[Transform3D] = []
var accent_colors: Array[Color] = []
var canopy_transforms: Array[Transform3D] = []

func _ready() -> void:
 _environment()
 _start_ambience("city" if preview_kind == "city" else "mountain")
 if preview_kind == "city": _city()
 else: _mountain()
 _flush_accents()
 _flush_canopies()
 _scene_population()
 player = HotelPlayer.new()
 player.position = Vector3(0,0.05,20)
 add_child(player)
 player.mouse_sensitivity = float(Campaign.settings["sensitivity"])
 var canvas := CanvasLayer.new()
 add_child(canvas)
 hud = Label.new()
 hud.position = Vector2(24,20)
 hud.add_theme_font_size_override("font_size", 20)
 hud.add_theme_color_override("font_shadow_color", Color.BLACK)
 hud.add_theme_constant_override("shadow_offset_x", 2)
 hud.add_theme_constant_override("shadow_offset_y", 2)
 canvas.add_child(hud)

func footstep_surface(point: Vector3) -> String:
 if preview_kind == "mountain" and absf(point.x) > 5.5: return "grass"
 return "stone"

func _accent(pos: Vector3, size: Vector3, color: Color) -> void:
 accents.append(Transform3D(Basis.IDENTITY.scaled(size),pos))
 accent_colors.append(color)

func _flush_accents() -> void:
 if accents.is_empty(): return
 var multi := MultiMesh.new()
 multi.transform_format = MultiMesh.TRANSFORM_3D
 multi.use_colors = true
 var mesh := BoxMesh.new()
 var material := StandardMaterial3D.new()
 material.vertex_color_use_as_albedo = true
 material.roughness = 0.82
 mesh.material = material
 multi.mesh = mesh
 multi.instance_count = accents.size()
 for i: int in range(accents.size()):
  multi.set_instance_transform(i, accents[i])
  multi.set_instance_color(i, accent_colors[i])
 var visual := MultiMeshInstance3D.new()
 visual.name = "DistrictDetails"
 visual.multimesh = multi
 visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(visual)

func _flush_canopies() -> void:
 if canopy_transforms.is_empty(): return
 var multi := MultiMesh.new()
 multi.transform_format = MultiMesh.TRANSFORM_3D
 var mesh := SphereMesh.new()
 mesh.radius = 0.5
 mesh.height = 1.0
 mesh.radial_segments = 8
 mesh.rings = 4
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(0.22,0.39,0.23)
 material.roughness = 0.95
 mesh.material = material
 multi.mesh = mesh
 multi.instance_count = canopy_transforms.size()
 for i: int in range(canopy_transforms.size()): multi.set_instance_transform(i,canopy_transforms[i])
 var trees := MultiMeshInstance3D.new()
 trees.name = "TreeCanopies"
 trees.multimesh = multi
 trees.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(trees)

# A compact, four-sided facade system keeps the city readable when the camera
# turns. Shallow, non-colliding bays sit on the solid building shell; they are
# architectural openings and framing, not false doors or extra walkable space.
func _city_facade_glass(operation: String, level_index: int, bay_index: int, x: float, z: float) -> Color:
 var glass_palette: Array[Color] = [Color(0.14,0.29,0.34),Color(0.20,0.37,0.41),Color(0.28,0.40,0.41),Color(0.34,0.39,0.38)]
 var tint: Color = glass_palette[(bay_index+level_index+int(absf(x+z))%4)%glass_palette.size()]
 if operation == "the_district" and level_index % 2 == 0:
  tint = Color(0.24,0.43,0.47)
 elif operation == "the_harbour":
  tint = Color(0.25,0.46,0.49) if level_index % 2 == 0 else Color(0.17,0.34,0.39)
 return tint

func _build_city_block_facade(x: float, z: float, height: float, wall: Color) -> void:
 var operation := str(get_meta("operation_id", ""))
 var frame := wall.darkened(0.42)
 var sill := wall.lightened(0.12)
 var facade_windows := 0
 var levels: Array[float] = [2.05,4.35,6.65,8.95]
 for level_index: int in range(levels.size()):
  var y: float = levels[level_index]
  if y + 0.72 >= height: continue
  for bay_index: int in range(3):
   var offset: float = [-2.85,0.0,2.85][bay_index]
   # Side street facades on both X ends.
   for side: float in [-1.0,1.0]:
    var face_x: float = x + side*5.035
    var pane_z: float = z + offset
    _accent(Vector3(face_x,y,pane_z),Vector3(0.07,1.38,1.68),_city_facade_glass(operation,level_index,bay_index,x,z))
    _accent(Vector3(face_x+side*0.055,y,pane_z-0.88),Vector3(0.10,1.50,0.08),frame)
    _accent(Vector3(face_x+side*0.055,y,pane_z+0.88),Vector3(0.10,1.50,0.08),frame)
    _accent(Vector3(face_x+side*0.06,y-0.75,pane_z),Vector3(0.16,0.09,1.82),sill)
    _accent(Vector3(face_x+side*0.06,y+0.75,pane_z),Vector3(0.10,0.08,1.82),frame)
    _accent(Vector3(face_x+side*0.07,y,pane_z),Vector3(0.12,1.35,0.055),frame)
    facade_windows += 1
   # The rear facade is fully articulated. The street-facing facade keeps its
   # ground floor open for the authored shopfront/entry while upper floors read.
   for side: float in [-1.0,1.0]:
    if side > 0.0 and level_index == 0: continue
    var face_z: float = z + side*4.535
    var pane_x: float = x + offset
    _accent(Vector3(pane_x,y,face_z),Vector3(1.68,1.38,0.07),_city_facade_glass(operation,level_index,bay_index,x,z))
    _accent(Vector3(pane_x-0.88,y,face_z+side*0.055),Vector3(0.08,1.50,0.10),frame)
    _accent(Vector3(pane_x+0.88,y,face_z+side*0.055),Vector3(0.08,1.50,0.10),frame)
    _accent(Vector3(pane_x,y-0.75,face_z+side*0.06),Vector3(1.82,0.09,0.16),sill)
    _accent(Vector3(pane_x,y+0.75,face_z+side*0.055),Vector3(1.82,0.08,0.10),frame)
    _accent(Vector3(pane_x,y,face_z+side*0.07),Vector3(0.055,1.35,0.12),frame)
    facade_windows += 1
   # A few upper-floor balconies create depth on the office and harbour blocks;
   # solid guard rails are deliberate, visible edges, not walkable platforms.
   if operation in ["the_district","the_harbour"] and bay_index == 1 and level_index == 1 and (int(absf(x+z)) % 2 == 0):
    var balcony_x := x + 5.18
    _accent(Vector3(balcony_x,y-0.9,z+offset),Vector3(0.75,0.12,2.25),frame)
    _accent(Vector3(balcony_x+0.32,y-0.35,z+offset),Vector3(0.06,0.95,2.25),sill)
    for rail_z: float in [-0.9,0.0,0.9]:
     _accent(Vector3(balcony_x+0.32,y-0.35,z+offset+rail_z),Vector3(0.06,0.95,0.055),frame)
 # Air-conditioning condensers and rain leaders are placed sparingly on service
 # sides, a functional response to the dense humid-city building type.
 if int(absf(x-z)) % 3 == 0:
  for level_index: int in range(1,mini(3,levels.size())):
   var y: float = levels[level_index]
   if y+0.3 >= height: continue
   var side_x := x-5.18
   _accent(Vector3(side_x,y-0.92,z+2.8),Vector3(0.48,0.42,0.72),frame.lightened(0.12))
   for vent: float in [-0.12,0.0,0.12]:
    _accent(Vector3(side_x-0.25,y-0.92,z+2.8+vent),Vector3(0.035,0.30,0.045),frame.darkened(0.22))
 for side: float in [-1.0,1.0]:
  _accent(Vector3(x+side*4.86,height+0.18,z),Vector3(0.22,0.32,9.25),frame)
  _accent(Vector3(x,height+0.18,z+side*4.37),Vector3(10.0,0.32,0.22),frame)
 # A narrow rooftop plant screen gives each building a believable service edge.
 if int(absf(x+z)) % 3 == 1:
  for side: float in [-1.0,1.0]:
   _accent(Vector3(x+side*2.9,height+0.75,z),Vector3(0.12,1.1,4.7),frame)
  _accent(Vector3(x,height+0.75,z-2.3),Vector3(5.8,1.1,0.12),frame)
 set_meta("city_facade_bays",int(get_meta("city_facade_bays",0))+facade_windows)

# Fictional accessible upper walkway; it is not connected to the NPC navmesh.
func _city_walkway() -> void:
 var ramp := StaticBody3D.new()
 ramp.name = "CityWalkwayRamp"
 ramp.position = Vector3(12,1.10,0)
 ramp.rotation.z = atan(2.4 / 6.0)
 add_child(ramp)
 var size := Vector3(6.5,0.2,2.8)
 var mesh := BoxMesh.new()
 mesh.size = size
 var visual := MeshInstance3D.new()
 visual.mesh = mesh
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(0.38,0.40,0.38)
 material.roughness = 0.88
 visual.material_override = material
 ramp.add_child(visual)
 var collider := CollisionShape3D.new()
 var shape := BoxShape3D.new()
 shape.size = size
 collider.shape = shape
 ramp.add_child(collider)
 for z: float in [-1.35,1.35]:
  var rail := MeshInstance3D.new()
  var rail_mesh := BoxMesh.new()
  rail_mesh.size = Vector3(6.5,0.08,0.08)
  rail.mesh = rail_mesh
  rail.position = Vector3(0,0.9,z)
  rail.material_override = material
  ramp.add_child(rail)
 # The terrace overlaps the ramp slightly below its high end, so the
 # character capsule does not collide with a raised vertical lip on ascent.
 _box(Vector3(19,2.0,0),Vector3(8.5,0.3,8),Color(0.44,0.45,0.41),true)
 for z: float in [-4.0,4.0]:
  _box(Vector3(19,2.70,z),Vector3(8.5,1.1,0.10),Color(0.25,0.32,0.32),true)
 _box(Vector3(23.2,2.70,0),Vector3(0.10,1.1,8),Color(0.25,0.32,0.32),true)
 _sign("PUBLIC WALKWAY", Vector3(16.5,4.2,-3.8),30)

# Gently rolling terrain meshes meet the surrounding ground at their edges.
# Physics uses the same triangles as the visible terrain, not a flat fake floor.
func _terrain_patch(x0: float, z0: float, width: float, depth: float, height: float) -> void:
 var divisions := 12
 var surface := SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for ix: int in range(divisions):
  for iz: int in range(divisions):
   var points: Array[Vector3] = []
   # Godot's front-facing triangle winding also determines the solid side
   # of the concave collision mesh. Reversing this makes an uphill walk hit
   # the underside of the terrain and stick at the seam with the flat floor.
   for corner: Vector2i in [Vector2i(0,0),Vector2i(1,1),Vector2i(0,1),Vector2i(0,0),Vector2i(1,0),Vector2i(1,1)]:
    var u := float(ix+corner.x)/float(divisions)
    var v := float(iz+corner.y)/float(divisions)
    var y := maxf(0.0, sin(PI*u) * sin(PI*v)) * height
    points.append(Vector3(x0+u*width,y,z0+v*depth))
   for point: Vector3 in points: surface.add_vertex(point)
 surface.generate_normals()
 var mesh := surface.commit()
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(0.31,0.43,0.30)
 material.roughness = 1.0
 material.cull_mode = BaseMaterial3D.CULL_DISABLED
 var body := StaticBody3D.new()
 body.name = "MountainTerrain"
 add_child(body)
 var visual := MeshInstance3D.new()
 visual.mesh = mesh
 visual.material_override = material
 body.add_child(visual)
 var collider := CollisionShape3D.new()
 collider.shape = mesh.create_trimesh_shape()
 body.add_child(collider)

func _village_roof(center: Vector3) -> void:
 var surface := SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var a := Vector3(-4,0,-4)
 var b := Vector3(4,0,-4)
 var c := Vector3(4,0,4)
 var d := Vector3(-4,0,4)
 var e := Vector3(-4,1.2,0)
 var f := Vector3(4,1.2,0)
 for p: Vector3 in [a,b,f,a,f,e, d,e,f,d,f,c, a,e,d, b,c,f]: surface.add_vertex(p)
 surface.generate_normals()
 var visual := MeshInstance3D.new()
 visual.mesh = surface.commit()
 visual.position = center
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(0.40,0.17,0.13)
 material.roughness = 0.9
 material.cull_mode = BaseMaterial3D.CULL_DISABLED
 visual.material_override = material
 add_child(visual)

func _scene_population() -> void:
 # Short, explicitly unobstructed routes in public space; no cross-district AI.
 var roles := ["civilian", "employee", "civilian", "civilian"]
 var routes := [
  [Vector3(-2,0.05,9), Vector3(-2,0.05,-9)],
  [Vector3(2,0.05,-8), Vector3(2,0.05,8)],
  [Vector3(-7,0.05,2), Vector3(7,0.05,2)],
  [Vector3(7,0.05,-2), Vector3(-7,0.05,-2)]]
 if preview_kind == "mountain":
  routes = [
   [Vector3(-2,0.05,10), Vector3(-2,0.05,-10)],
   [Vector3(2,0.05,-9), Vector3(2,0.05,9)],
   [Vector3(-4,0.05,5), Vector3(4,0.05,5)]]
 var coats: Array[Color] = [Color(0.31,0.40,0.48), Color(0.49,0.33,0.23), Color(0.40,0.45,0.32), Color(0.52,0.43,0.41)]
 for i: int in range(routes.size()):
  var person := _target(("Visitor " if preview_kind == "mountain" else "Commuter ") + str(i+1), roles[i], routes[i][0], routes[i][1])
  person.person.clothing.albedo_color = coats[i]

func _process(_delta: float) -> void:
 var title := "HONG KONG  /  CITY SANDBOX" if preview_kind == "city" else "NGONG PING  /  TIAN TAN BUDDHA"
 hud.text = title + "  —  EXPLORATION PREVIEW\nWASD MOVE   ·   MOUSE LOOK   ·   ESC MAP SELECTION"

func _ground(color: Color) -> void:
 var op := str(get_meta("operation_id", ""))
 if op == "ngong_ping" or preview_kind == "mountain":
  # The narrow void in the public plaza is entirely behind the Buddha plinth
  # and roofed by the hidden access corridor; the surface does not seal it.
  _box(Vector3(-24.25,-0.2,-5),Vector3(41.5,0.4,100),color,true)
  _box(Vector3(24.25,-0.2,-5),Vector3(41.5,0.4,100),color,true)
  # A narrow, buried corridor continues under the plinth to the concealed
  # statue-interior stair. Both openings remain covered by the stone shell.
  _box(Vector3(0,-0.2,-31.0),Vector3(7,0.4,14),color,true)
  _box(Vector3(0,-0.2,13.5),Vector3(7,0.4,75),color,true)
 else:
  _box(Vector3(0,-0.2,0), Vector3(90,0.4,90), color, true)
 for x: float in [-45.0,45.0]:
  var open_gateway := op == "hong_kong_sandbox" or (x < 0.0 and op == "the_streets") or (x > 0.0 and op == "the_district")
  if open_gateway:
   for z: float in [-25.5,25.5]: _box(Vector3(x,2,z),Vector3(0.3,4,39),color.darkened(0.2),true)
  else: _box(Vector3(x,2,-5 if op == "ngong_ping" else 0),Vector3(0.3,4,100 if op == "ngong_ping" else 90),color.darkened(0.2),true)
 for z: float in [-45.0,45.0]:
  var boundary_z := -55.0 if op == "ngong_ping" and z < 0.0 else z
  if z < 0.0 and op == "ngong_ping":
   for x: float in [-25.5,25.5]: _box(Vector3(x,2,boundary_z),Vector3(39,4,0.3),color.darkened(0.2),true)
  elif z < 0.0 and (op == "the_harbour" or op == "hong_kong_sandbox"):
   for x: float in [-25.5,25.5]: _box(Vector3(x,2,boundary_z),Vector3(39,4,0.3),color.darkened(0.2),true)
  else: _box(Vector3(0,2,boundary_z),Vector3(90,4,0.3),color.darkened(0.2),true)

# Parked street vehicles are fictional low-poly props, not controllable. Their
# simple body collider is outside all public-space NPC routes and the ramp.
func _parked_car(x: float, z: float, paint: Color) -> void:
 var dark := Color(0.11,0.15,0.16)
 _box(Vector3(x,0.48,z),Vector3(2.25,0.72,4.1),paint,true)
 _accent(Vector3(x,1.03,z-0.15),Vector3(1.90,0.65,2.0),paint.darkened(0.08))
 _accent(Vector3(x,1.05,z-1.17),Vector3(1.67,0.43,0.035),Color(0.28,0.42,0.45))
 _accent(Vector3(x,1.05,z+0.87),Vector3(1.67,0.43,0.035),Color(0.28,0.42,0.45))
 for side: float in [-1.0,1.0]:
  _accent(Vector3(x+side*1.14,1.06,z-0.15),Vector3(0.04,0.40,1.75),Color(0.25,0.38,0.41))
  for dz: float in [-1.3,1.3]:
   _accent(Vector3(x+side*1.14,0.30,z+dz),Vector3(0.22,0.54,0.70),dark)
 for dx: float in [-0.78,0.78]:
  _accent(Vector3(x+dx,0.55,z-2.07),Vector3(0.30,0.17,0.04),Color(0.93,0.82,0.57))
  _accent(Vector3(x+dx,0.55,z+2.07),Vector3(0.30,0.17,0.04),Color(0.68,0.16,0.12))

func _parked_bus(x: float, z: float) -> void:
 var red := Color(0.58,0.20,0.16)
 var glass := Color(0.23,0.36,0.39)
 _box(Vector3(x,1.76,z),Vector3(2.4,3.5,7.2),red,true)
 for side: float in [-1.0,1.0]:
  for y: float in [1.35,2.75]:
   for dz: float in [-2.7,-1.35,0.0,1.35,2.7]:
    _accent(Vector3(x+side*1.21,y,z+dz),Vector3(0.04,0.8,1.1),glass)
  for dz: float in [-2.2,2.2]:
   _accent(Vector3(x+side*1.22,0.35,z+dz),Vector3(0.25,0.66,0.85),Color(0.10,0.12,0.13))
 _accent(Vector3(x,2.55,z-3.61),Vector3(2.0,0.75,0.04),glass)
 _accent(Vector3(x,1.18,z-3.61),Vector3(2.0,0.75,0.04),glass)
 _accent(Vector3(x,3.20,z-3.63),Vector3(1.7,0.20,0.04),Color(0.90,0.74,0.43))

func _city() -> void:
 _ground(Color(0.34,0.36,0.36))
 var road := Color(0.20,0.23,0.25)
 var pale := Color(0.76,0.68,0.52)
 var dark := Color(0.18,0.25,0.27)
 var glass: Color = _city_facade_glass(str(get_meta("operation_id", "")),1,1,0.0,0.0)
 _box(Vector3(0,0.02,0),Vector3(11,0.04,88),road)
 _box(Vector3(0,0.025,0),Vector3(88,0.04,10),road)
 for z: float in [-36.0,-24.0,-12.0,0.0,12.0,24.0,36.0]:
  _box(Vector3(0,0.06,z),Vector3(0.16,0.03,4),pale)
 # Blocks with open passages around them form a connected set of streets.
 for x: float in [-31.0,-17.0,17.0,31.0]:
  for z: float in [-30.0,-16.0,16.0,30.0]:
   var h := 6.0 + absf(x + z) * 0.09
   if _is_operation_interior(x, z):
    _operation_interior(x, z)
    continue
   var building := Color(0.42+absf(x)*0.002,0.44,0.42+absf(z)*0.002)
   _box(Vector3(x,h/2,z),Vector3(10,h,9),building,true)
   _box(Vector3(x,0.3,z+4.9),Vector3(10,0.6,0.8),dark)
   _build_city_block_facade(x,z,h,building)
   # Setback roof volumes vary the silhouette without creating fake interiors.
   var extra_height := 2.5 + float(int(absf(x+z)) % 4) * 0.8
   _accent(Vector3(x,h+extra_height*0.5,z),Vector3(7.8,extra_height,6.8),building.darkened(0.1))
   _accent(Vector3(x,h+extra_height+0.25,z),Vector3(8.1,0.5,7.1),dark)
   for dx: float in [-2.3,0.0,2.3]:
    _accent(Vector3(x+dx,h+extra_height*0.55,z+3.43),Vector3(1.2,extra_height*0.6,0.04),glass)
 _city_walkway()
 _city_street_infrastructure()
 # Parked cars, a double-decker and crossings make the public street legible.
 # Their bodies are solid and lie beyond the short central visitor routes.
 _parked_car(-8.9,20,Color(0.67,0.18,0.15))
 _parked_car(8.9,-18,Color(0.38,0.43,0.42))
 _parked_bus(-9.2,-27)
 for z: float in [-5.8,5.8]:
  for x: float in [-4.5,-3.0,-1.5,0.0,1.5,3.0,4.5]:
   _accent(Vector3(x,0.075,z),Vector3(0.75,0.02,1.25),Color(0.78,0.76,0.67))
 # A layered skyline is scenic outside the walkable boundary, not interiors.
 for i: int in range(13):
  var x := -45.0 + float(i)*7.5
  var h := 10.0 + float((i*11)%7)*1.3
  # Keep the waterfront gateway visibly open as well as physically open.
  if str(get_meta("operation_id", "")) in ["the_harbour", "hong_kong_sandbox"] and absf(x) < 8.0: continue
  _accent(Vector3(x,h*0.5,-49),Vector3(6.8,h,3.0),Color(0.20+float(i%3)*0.025,0.28,0.31))
  for y: float in [4.0,7.0,10.0]:
   if y < h - 0.5:
    for dx: float in [-2.0,0.0,2.0]:
     _accent(Vector3(x+dx,y,-47.47),Vector3(0.7,0.9,0.05),Color(0.52,0.54,0.45))
 # Market stalls, pedestrian streets and waterfront promenade.
 for x: float in [-30.0,-24.0,-18.0,-12.0]:
  _box(Vector3(x,0.55,8),Vector3(3.8,1.1,1.8),Color(0.38,0.25,0.17),true)
  _box(Vector3(x,2.2,8),Vector3(4.1,0.12,2.4),Color(0.67,0.25,0.18))
  for side: float in [-1.7,1.7]: _box(Vector3(x+side,1.3,8),Vector3(0.1,2.5,0.1),dark)
 _sign("MARKET STREET",Vector3(-21,3.0,5),38)
 _sign("COMMERCIAL DISTRICT",Vector3(18,3.0,-6),38)
 _sign("BACKSTREETS",Vector3(-21,3.0,-8),38)
 for entry: Array in [["JADE TEA",Vector3(-11.90,3.2,16.0),PI/2], ["NORTH MARKET",Vector3(-11.90,3.2,30.0),PI/2], ["HARBOUR OFFICE",Vector3(11.90,3.2,-16.0),-PI/2], ["CENTRAL ARCADE",Vector3(11.90,3.2,16.0),-PI/2]]:
  var placard := Label3D.new()
  placard.text = entry[0]
  placard.position = entry[1]
  placard.rotation.y = entry[2]
  placard.font_size = 38
  placard.pixel_size = 0.004
  placard.modulate = Color(0.90,0.78,0.58)
  add_child(placard)
 _box(Vector3(0,0.03,-40),Vector3(84,0.06,5),Color(0.27,0.38,0.40))
 _box(Vector3(0,0.03,-43),Vector3(84,0.06,3),Color(0.14,0.30,0.38))
 _sign("HARBOUR PROMENADE",Vector3(0,3,-37),38)
 # Facade bays, awnings and signs establish distinct public-facing streets.
 for x: float in [-31.0,-17.0,17.0,31.0]:
  for z: float in [-30.0,-16.0,16.0,30.0]:
   if _is_operation_interior(x, z): continue
   _accent(Vector3(x,3.5,z+4.62),Vector3(9.8,0.15,0.12),Color(0.69,0.62,0.49))
   _accent(Vector3(x,0.13,z+5.2),Vector3(10.4,0.20,0.7),Color(0.49,0.49,0.45))
   for dx: float in [-3.8,3.8]:
    _accent(Vector3(x+dx,1.8,z+4.63),Vector3(0.15,3.4,0.12),Color(0.31,0.33,0.31))
   _accent(Vector3(x,2.8,z+4.75),Vector3(6.8,0.34,0.15),Color(0.18,0.28,0.30))
   _accent(Vector3(x,1.65,z+4.68),Vector3(5.5,1.65,0.06),Color(0.29,0.42,0.43))
 for x: float in [-30.0,-24.0,-18.0,-12.0]:
  for dx: float in [-1.2,0.0,1.2]:
   _accent(Vector3(x+dx,1.21,8),Vector3(0.7,0.22,0.7),Color(0.52,0.57,0.27) if dx == 0.0 else Color(0.66,0.39,0.21))
  _accent(Vector3(x,2.26,8),Vector3(3.9,0.1,2.2),Color(0.73,0.30,0.20))
  for dx: float in [-1.3,0.0,1.3]:
   _accent(Vector3(x+dx,2.28,8),Vector3(0.35,0.12,2.2),Color(0.89,0.75,0.55))
 for x: float in [-36.0,-28.0,-20.0,-12.0,-4.0,4.0,12.0,20.0,28.0,36.0]:
  _accent(Vector3(x,0.8,-39.7),Vector3(0.08,1.6,0.08),Color(0.56,0.61,0.57))
 _accent(Vector3(0,1.45,-39.7),Vector3(80,0.08,0.08),Color(0.56,0.61,0.57))
 for z: float in [-25.0,-15.0,-5.0,5.0,15.0,25.0]:
  for x: float in [-7.3,7.3]:
   _accent(Vector3(x,1.9,z),Vector3(0.11,3.8,0.11),Color(0.22,0.27,0.26))
   _accent(Vector3(x,3.85,z),Vector3(0.65,0.10,0.45),Color(0.94,0.78,0.56))
 for x: float in [-35.0,-25.0,-15.0,-5.0,5.0,15.0,25.0,35.0]:
  _box(Vector3(x,1.4,-38),Vector3(0.12,2.8,0.12),dark)
  _box(Vector3(x,2.85,-38),Vector3(0.7,0.1,0.7),Color(0.95,0.80,0.58))
 var op := str(get_meta("operation_id", ""))
 if op in ["the_streets", "the_district", "the_harbour"]:
  _attach_city_district(op)
 elif op == "hong_kong_sandbox":
  # The three neighbourhood builders join the shared city through open,
  # walkable gateways. They are all instanced in this one scene and one save.
  _attach_city_district("the_streets")
  _attach_city_district("the_district")
  _attach_city_district("the_harbour")
 if op in ["the_harbour", "hong_kong_sandbox"]:
  _harbour_waterfront()

# Street furniture and drainage follow the curb line as a coherent municipal
# system. The service items sit at block edges, leaving the existing traversal
# lanes and the mission's collision/nav polygons untouched.
func _city_street_infrastructure() -> void:
 var curb := Color(0.46,0.48,0.45)
 var pavement := Color(0.39,0.41,0.39)
 var dark_metal := Color(0.12,0.18,0.19)
 var tactile := Color(0.78,0.64,0.39)
 for side: float in [-1.0,1.0]:
  var street_x := side*5.78
  CONSTRUCTION.box(self,"RaisedNorthSouthFootpath",Vector3(side*7.15,0.045,0),Vector3(2.6,0.09,86),pavement,0.9)
  for segment: int in range(8):
   var z0 := -42.0+float(segment)*10.5
   CONSTRUCTION.box(self,"NorthSouthKerb",Vector3(street_x,0.12,z0+5.0),Vector3(0.22,0.24,9.8),curb,0.72)
   CONSTRUCTION.box(self,"StormDrainFrame",Vector3(side*5.46,0.075,z0+5.0),Vector3(0.44,0.035,1.1),dark_metal,0.58)
   for slot: int in range(5):
    CONSTRUCTION.box(self,"StormDrainSlot",Vector3(side*5.46,0.096,z0+4.58+float(slot)*0.19),Vector3(0.34,0.012,0.035),Color(0.43,0.49,0.47),0.5)
  for z: float in [-30.0,-12.0,12.0,30.0]:
   var pole_x := side*7.05
   CONSTRUCTION.box(self,"StreetLampPlinth",Vector3(pole_x,0.19,z),Vector3(0.48,0.38,0.48),dark_metal,0.62)
   CONSTRUCTION.box(self,"StreetLampPost",Vector3(pole_x,2.75,z),Vector3(0.12,5.2,0.12),Color(0.23,0.29,0.28),0.48)
   CONSTRUCTION.box(self,"StreetLampArm",Vector3(pole_x-side*0.38,5.20,z),Vector3(0.82,0.10,0.12),Color(0.23,0.29,0.28),0.45)
   CONSTRUCTION.box(self,"StreetLampHead",Vector3(pole_x-side*0.78,5.12,z),Vector3(0.68,0.14,0.34),Color(0.94,0.76,0.48),0.4,1.3)
   if z in [-12.0,12.0]:
    var cabinet := CONSTRUCTION.box(self,"TelecomServiceCabinet",Vector3(pole_x-side*0.55,0.70,z+1.2),Vector3(0.72,1.36,0.62),Color(0.31,0.38,0.36),0.7)
    cabinet.set_meta("service_access",true)
    for vent: int in range(4):
     CONSTRUCTION.box(self,"CabinetVent",Vector3(pole_x-side*0.55,0.90+float(vent)*0.12,z+0.88),Vector3(0.40,0.025,0.025),dark_metal,0.5)
  # Distinct paired overhead service cables connect the poles rather than
  # floating as isolated decorative wires.
  CONSTRUCTION.trim_run(self,"TelecomSpan",Vector3(side*7.05,5.08,-30.0),Vector3(side*7.05,5.08,-12.0),0.045,dark_metal)
  CONSTRUCTION.trim_run(self,"TelecomSpan",Vector3(side*7.05,5.08,12.0),Vector3(side*7.05,5.08,30.0),0.045,dark_metal)
 for side: float in [-1.0,1.0]:
  var street_z := side*5.25
  CONSTRUCTION.box(self,"EastWestFootpath",Vector3(0,0.045,side*6.75),Vector3(86,0.09,2.7),pavement,0.9)
  for segment: int in range(8):
   var x0 := -42.0+float(segment)*10.5
   CONSTRUCTION.box(self,"EastWestKerb",Vector3(x0+5.0,0.12,street_z),Vector3(9.8,0.24,0.22),curb,0.72)
  # Tactile paving is set only at the existing crossing approaches.
  for crossing_x: float in [-4.8,4.8]:
   CONSTRUCTION.box(self,"TactileCrossingPad",Vector3(crossing_x,0.085,side*6.32),Vector3(0.72,0.04,0.72),tactile,0.9)
 # One practical bus shelter on the public route: roof, wind screens, bench,
 # timetable case and a clear standing bay. It stays outside the car path.
 var shelter := Vector3(8.0,0.0,22.0)
 CONSTRUCTION.box(self,"BusShelterFooting",shelter+Vector3(0.0,0.07,0.0),Vector3(4.4,0.14,2.3),Color(0.35,0.39,0.37),0.9)
 CONSTRUCTION.box(self,"BusShelterRoof",shelter+Vector3(0.0,2.55,0.0),Vector3(4.6,0.18,2.5),Color(0.17,0.27,0.29),0.55)
 for x_offset: float in [-2.1,2.1]:
  CONSTRUCTION.box(self,"BusShelterPost",shelter+Vector3(x_offset,1.28,0.0),Vector3(0.10,2.55,0.10),Color(0.20,0.29,0.30),0.48)
 for x_offset: float in [-1.12,1.12]:
  CONSTRUCTION.glazed_bay(self,"ShelterWindScreen",shelter+Vector3(x_offset,1.30,-0.88),1.95,2.25,0.06,Color(0.26,0.35,0.34),Color(0.31,0.50,0.51,0.42),1)
 CONSTRUCTION.box(self,"ShelterBenchSeat",shelter+Vector3(0.0,0.52,0.50),Vector3(3.5,0.13,0.45),Color(0.34,0.29,0.22),0.7)
 CONSTRUCTION.box(self,"ShelterBenchBack",shelter+Vector3(0.0,0.94,0.72),Vector3(3.5,0.68,0.11),Color(0.24,0.34,0.34),0.74)
 CONSTRUCTION.box(self,"TimetableCase",shelter+Vector3(2.35,1.58,-0.88),Vector3(0.58,1.18,0.12),Color(0.74,0.66,0.48),0.6)
 CONSTRUCTION.box(self,"TimetableGlazing",shelter+Vector3(2.35,1.58,-0.95),Vector3(0.46,0.95,0.025),Color(0.22,0.41,0.44),0.22)

# Give the harbour operation a real waterfront horizon: layered water, a
# working-ferry silhouette, distant tower clusters and low island forms. All
# added details stay beyond the playable boundary and are batched as accents.
func _harbour_waterfront() -> void:
 var first_detail := accents.size()
 _accent(Vector3(0.0,-0.10,-142.0),Vector3(180.0,0.16,56.0),Color(0.12,0.29,0.35))
 for row: int in range(7):
  var z := -119.0-float(row)*7.2
  var phase := float(row%3)*4.5
  for segment: int in range(5):
   var x := -64.0+float(segment)*29.0+phase
   _accent(Vector3(x,-0.105,z),Vector3(15.0+float((row+segment)%3)*3.0,0.025,0.07),Color(0.25,0.45,0.48) if row%2==0 else Color(0.18,0.37,0.42))
 # A restrained two-deck ferry anchors scale on the water without adding a
 # moving obstacle or changing the mission's walkable footprint.
 _accent(Vector3(16.0,0.25,-132.0),Vector3(11.0,0.85,3.6),Color(0.72,0.71,0.63))
 _accent(Vector3(16.0,0.87,-132.1),Vector3(5.4,1.05,2.7),Color(0.80,0.78,0.68))
 _accent(Vector3(16.0,1.0,-130.72),Vector3(4.8,0.48,0.035),Color(0.19,0.39,0.43))
 _accent(Vector3(16.0,1.0,-133.47),Vector3(4.8,0.48,0.035),Color(0.19,0.39,0.43))
 _accent(Vector3(16.0,0.12,-132.0),Vector3(8.5,0.10,3.15),Color(0.69,0.18,0.14))
 for x: float in [13.9,15.3,16.7,18.1]:
  _accent(Vector3(x,1.12,-130.68),Vector3(0.85,0.43,0.035),Color(0.24,0.44,0.48))
 # Distant high-rise silhouettes add the dense vertical cadence of a harbour
 # skyline while keeping their windows broad enough to read at play distance.
 for tower: int in range(11):
  var x := -70.0+float(tower)*14.0
  var height := 18.0+float((tower*13)%8)*4.2
  var width := 8.5+float(tower%3)*2.0
  var wall := Color(0.20,0.30,0.34).lightened(float(tower%3)*0.025)
  _accent(Vector3(x,height*0.5,-185.0),Vector3(width,height,5.0),wall)
  _accent(Vector3(x,height+0.18,-185.0),Vector3(width+0.5,0.32,5.5),Color(0.25,0.34,0.37))
  for floor_index: int in range(1,int(height/4.2)):
   var window_y := 1.8+float(floor_index)*4.2
   for pane: float in [-width*0.28,0.0,width*0.28]:
    var warm := (tower+floor_index+int(absf(pane)))%5==0
    _accent(Vector3(x+pane,window_y,-182.42),Vector3(1.55,1.65,0.07),Color(0.70,0.57,0.38) if warm else Color(0.29,0.47,0.51))
  if tower%3==1:
   _accent(Vector3(x,height+1.0,-185.0),Vector3(1.0,1.8,0.8),Color(0.20,0.28,0.31))
 # The ridgeline is deliberately low and softened so the towers remain the
 # focal distance; it frames rather than competes with the original city.
 for index: int in range(5):
  var x := -72.0+float(index)*36.0
  _peak(Vector3(x,-1.5,-200.0),18.0+float(index%2)*5.0,18.0+float(index%3)*4.0,Color(0.20,0.31,0.33))
 set_meta("harbour_waterfront_detail_count",accents.size()-first_detail)

func _attach_city_district(district_id: String) -> void:
 var annex := preload("res://scripts/world/hong_kong_annex.gd").new()
 annex.operation_id = district_id
 annex.name = "District_" + district_id
 if district_id == "the_streets":
  annex.position = Vector3(-45,0,0)
  annex.rotation.y = -PI/2.0
 elif district_id == "the_district":
  annex.position = Vector3(45,0,0)
  annex.rotation.y = PI/2.0
 else:
  annex.position = Vector3(0,0,-45)
  annex.rotation.y = PI
 add_child(annex)
 annex.build()
 if district_id == "the_streets":
  access_zones.append({"rect":Rect2(-70.0,-24.0,17.0,13.0),"floor_min":-0.1,"floor_max":4.8,"area":"market_staff"})
  access_zones.append({"rect":Rect2(-75.0,-28.0,8.0,17.0),"floor_min":-0.1,"floor_max":4.8,"area":"service_corridor"})
 elif district_id == "the_district":
  access_zones.append({"rect":Rect2(55.0,-24.0,16.0,13.0),"floor_min":-0.1,"floor_max":4.8,"area":"office_staff"})
 elif district_id == "the_harbour":
  # Five tower levels stay within the moderate-height access footprint.
  access_zones.append({"rect":Rect2(13.0,-93.0,9.0,19.0),"floor_min":3.0,"floor_max":12.7,"area":"corporate_staff"})
  access_zones.append({"rect":Rect2(13.0,-93.0,9.0,19.0),"floor_min":12.7,"floor_max":17.0,"area":"executive_suite"})

# Three mission-specific, walk-in interiors replace (rather than overlap) a
# solid scenic block. The surrounding city remains a shared destination.
func _is_operation_interior(x: float, z: float) -> bool:
 var op := str(get_meta("operation_id", ""))
 return (op == "the_streets" and x == -17.0 and z == 16.0) or (op == "the_district" and x == 17.0 and z == 16.0) or (op == "the_harbour" and x == 17.0 and z == -30.0)

func _operation_interior(x: float, z: float) -> void:
 var op := str(get_meta("operation_id", ""))
 var wall := Color(0.60,0.57,0.49) if op == "the_streets" else (Color(0.45,0.52,0.51) if op == "the_district" else Color(0.52,0.49,0.42))
 var dark := Color(0.23,0.28,0.28)
 # Two ends are split around real 3 m doorways, giving each interior a
 # street-facing and a backstreet-facing route. Other walls and roof are solid.
 if op == "the_harbour":
  for side: float in [-1.0,1.0]:
   _box(Vector3(x+side*5,2.1,z),Vector3(0.25,4.2,9),wall,true)
   for end: float in [-1.0,1.0]:
    _box(Vector3(x+side*3.25,2.1,z+end*4.5),Vector3(3.5,4.2,0.25),wall,true)
 else:
  for side: float in [-1.0,1.0]:
   _box(Vector3(x,2.1,z+side*4.5),Vector3(10,4.2,0.25),wall,true)
   for end: float in [-1.0,1.0]:
    _box(Vector3(x+end*5.0,2.1,z+side*3.0),Vector3(0.25,4.2,3.0),wall,true)
 _box(Vector3(x,4.3,z),Vector3(10,0.2,9),dark,true)
 _box(Vector3(x,0.015,z),Vector3(9.7,0.03,8.7),Color(0.48,0.45,0.38))
 # A desk and wall fixtures are tucked away from the doorway and actor routes.
 var desk_x := x + (-3.0 if op == "the_streets" else 3.0)
 _box(Vector3(desk_x,0.5,z-2.8),Vector3(1.6,1.0,1.0),Color(0.36,0.25,0.18),true)
 _box(Vector3(desk_x,1.2,z-2.8),Vector3(0.65,0.5,0.12),Color(0.18,0.31,0.33))
 _box(Vector3(x,4.12,z),Vector3(2.8,0.08,0.6),Color(0.95,0.84,0.62))
 # Batched wall panels, skirting and a woven floor inset add material rhythm
 # without changing either doorway or the local navigation space.
 var accent := Color(0.42,0.30,0.24) if op == "the_streets" else (Color(0.25,0.39,0.39) if op == "the_district" else Color(0.38,0.30,0.24))
 _accent(Vector3(x,0.04,z),Vector3(3.2,0.02,4.1),accent.darkened(0.22))
 for side: float in [-1.0,1.0]:
  _accent(Vector3(x,0.18,z+side*4.34),Vector3(9.7,0.25,0.06),dark)
  for dx: float in [-3.0,0.0,3.0]:
   _accent(Vector3(x+dx,2.3,z+side*4.32),Vector3(1.5,1.2,0.05),accent)
   _accent(Vector3(x+dx,2.3,z+side*4.28),Vector3(1.30,1.0,0.04),accent.lightened(0.18))
  _accent(Vector3(x+side*4.75,3.85,z),Vector3(0.08,0.12,8.6),dark)
 var practical := OmniLight3D.new()
 practical.position = Vector3(x,3.8,z)
 practical.light_color = Color(1.0,0.83,0.65)
 practical.light_energy = 0.42
 practical.omni_range = 7.5
 practical.shadow_enabled = false
 practical.add_to_group("quality_practicals")
 practical.visible = Campaign.settings["graphics"] != "LOW" and bool(Campaign.settings["practicals"])
 add_child(practical)
 # Reuse the repository's attributed CC0 furniture, visual-only and placed
 # away from routes; the desk retains its separately authored collider.
 var furniture := preload("res://scripts/visuals/hotel_furniture.gd").new()
 furniture.name = "CityInteriorFurniture"
 add_child(furniture)
 furniture.call("_place", preload("res://assets/kenney_furniture/laptop.glb"), Vector3(desk_x,1.0,z-2.8), Vector3(0.132,0,-0.12), Vector3(1.2,1.2,1.2), 0.0)
 furniture.call("_place", preload("res://assets/kenney_furniture/books.glb"), Vector3(desk_x,1.0,z-2.3), Vector3(0.075,0,-0.047), Vector3(1.2,1.2,1.2), 0.0)
 furniture.call("_place", preload("res://assets/kenney_furniture/chairCushion.glb"), Vector3(desk_x,0,z+3.0), Vector3(0.10,0,-0.10), Vector3(1.8,1.8,1.8), 0.0)
 furniture.call("_place", preload("res://assets/kenney_furniture/pottedPlant.glb"), Vector3(x-3.8,0,z-3.6), Vector3.ZERO, Vector3(2.1,2.1,2.1), 0.0)
 var label := "MARKET OFFICE" if op == "the_streets" else ("DISTRICT RECORDS" if op == "the_district" else "HARBOUR LIAISON")
 _sign(label, Vector3(x,2.9,z+4.31), 34)
 var region := NavigationRegion3D.new()
 region.name = "InteriorLocalNavigation"
 var nav := NavigationMesh.new()
 nav.vertices = PackedVector3Array([Vector3(x-4.5,0,z-4.0),Vector3(x+4.5,0,z-4.0),Vector3(x+4.5,0,z+4.0),Vector3(x-4.5,0,z+4.0)])
 nav.add_polygon(PackedInt32Array([0,3,2,1]))
 region.navigation_mesh = nav
 add_child(region)

func _mountain() -> void:
 _ground(Color(0.36,0.46,0.34))
 var stone := Color(0.61,0.60,0.53)
 _terrain_patch(-43,-38,33,36,2.6)
 _terrain_patch(10,-38,33,36,2.9)
 if str(get_meta("operation_id", "")) == "ngong_ping": _mountain_field_office()
 var dark := Color(0.22,0.24,0.20)
 # Broad public approach. The statue is a non-destructible landmark.
 if preview_kind == "mountain":
  # Leave the concealed service shaft and descending ramp uncovered behind
  # the pedestal; the public approach terminates at the statue's front edge.
  _box(Vector3(0,0.03,11),Vector3(11,0.06,58),stone)
 else:
  _box(Vector3(0,0.03,0),Vector3(11,0.06,80),stone)
 _box(Vector3(0,0.06,-22),Vector3(26,0.12,18),stone.lightened(0.08))
 for x: float in [-22.0,-14.0,14.0,22.0]:
  _box(Vector3(x,1.5,13),Vector3(7,3,7),Color(0.65,0.53,0.39),true)
  _village_roof(Vector3(x,3.15,13))
  _accent(Vector3(x,3.18,9.0),Vector3(8.2,0.16,0.18),Color(0.30,0.18,0.14))
  _accent(Vector3(x,3.18,17.0),Vector3(8.2,0.16,0.18),Color(0.30,0.18,0.14))
  _box(Vector3(x,1.5,9.44),Vector3(5,1.7,0.05),Color(0.25,0.35,0.32))
 _sign("VILLAGE APPROACH",Vector3(0,3.2,12),38)
 # The landmark is intentionally a respectful, stylised public monument,
 # not a mission target. Its proportions are enlarged relative to visitors,
 # rather than presenting a six-metre miniature in the landscape.
 _buddha_plinth()
 _buddha_approach()
 # A broad lotus-like ring sits on the pedestal; it remains scenic only.
 for i: int in range(16):
  var angle := TAU * float(i) / 16.0
  var petal := _sphere(Vector3(cos(angle)*12.3,2.80,-29+sin(angle)*5.7),Vector3(3.8,0.65,2.5),Color(0.48,0.39,0.27))
  petal.rotation.y = -angle
 var landmark := Node3D.new()
 landmark.name = "ScenicBuddhaLandmark"
 landmark.position = Vector3(0,2.5,-29)
 landmark.scale = Vector3.ONE * 5.0
 add_child(landmark)
 # Original abstract seated figure, with no interaction or damage behavior.
 _landmark_part(landmark, Vector3(0,2.15,-29),Vector3(6.2,1.25,3.6),Color(0.38,0.31,0.23))
 _landmark_part(landmark, Vector3(0,3.35,-29),Vector3(3.6,2.8,2.0),Color(0.43,0.35,0.25))
 # Overlapping folded legs give the seated figure a distinct cross-legged base.
 for side: float in [-1.0,1.0]:
  var folded_leg := _landmark_part(landmark, Vector3(side*1.45,2.18,-27.72),Vector3(3.3,0.65,1.25),Color(0.41,0.33,0.24))
  folded_leg.rotation.z = side * 0.12
 # A restrained seated silhouette with a raised right hand and a hand in the
 # lap.  The landmark is purely scenic and has no target or damage behavior.
 _landmark_part(landmark, Vector3(2.0,2.85,-29),Vector3(1.0,2.0,0.9),Color(0.43,0.35,0.25))
 var raised_arm := _landmark_part(landmark, Vector3(-1.95,3.15,-28.75),Vector3(0.85,1.85,0.80),Color(0.43,0.35,0.25))
 raised_arm.rotation.z = -0.22
 _landmark_part(landmark, Vector3(-2.10,4.03,-28.50),Vector3(0.60,0.80,0.24),Color(0.47,0.38,0.27))
 # Separate raised fingers and thumb distinguish the blessing gesture.
 for finger: int in range(4):
  _landmark_part(landmark, Vector3(-2.32+float(finger)*0.14,4.47,-28.50),Vector3(0.11,0.35,0.14),Color(0.47,0.38,0.27))
 var thumb := _landmark_part(landmark, Vector3(-1.75,4.02,-28.48),Vector3(0.12,0.33,0.14),Color(0.47,0.38,0.27))
 thumb.rotation.z = -0.75
 _landmark_part(landmark, Vector3(1.10,2.35,-27.78),Vector3(1.2,0.45,0.55),Color(0.47,0.38,0.27))
 _landmark_part(landmark, Vector3(0,2.15,-27.85),Vector3(1.9,0.45,0.8),Color(0.47,0.38,0.27))
 for finger: int in range(4):
  _landmark_part(landmark, Vector3(0.58+float(finger)*0.13,2.42,-27.41),Vector3(0.10,0.10,0.38),Color(0.47,0.38,0.27))
 # Broad, low-contrast robe folds follow the chest rather than using signage.
 for y: float in [2.9,3.25,3.6]:
  var fold := _landmark_part(landmark, Vector3(0.25,y,-27.98),Vector3(2.5,0.10,0.12),Color(0.39,0.32,0.24))
  fold.rotation.z = -0.14
 var head := MeshInstance3D.new()
 var sphere := SphereMesh.new()
 sphere.radius = 0.75
 sphere.height = 1.5
 sphere.radial_segments = 24
 sphere.rings = 12
 head.mesh = sphere
 head.scale = Vector3(0.86,1.0,0.90)
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(0.47,0.38,0.27)
 material.roughness = 0.9
 head.material_override = material
 head.position = Vector3(0,5.0,-29) - Vector3(0,1.65,-29)
 landmark.add_child(head)
 _landmark_part(landmark, Vector3(0,5.75,-29),Vector3(0.55,0.5,0.55),Color(0.37,0.30,0.22))
 # Small stylised curls describe the hair cap rather than a generic head.
 for row: int in range(3):
  for column: int in range(-2,3):
   var x := float(column) * 0.24
   var y := 5.53 + float(row) * 0.12
   var z := -28.48 - float(row) * 0.10
   _landmark_part(landmark, Vector3(x,y,z),Vector3(0.18,0.18,0.18),Color(0.36,0.30,0.22))
 for x: float in [-0.72,0.72]:
  _landmark_part(landmark, Vector3(x,4.93,-28.94),Vector3(0.23,0.47,0.20),Color(0.46,0.37,0.26))
 for x: float in [-0.25,0.25]:
  _landmark_part(landmark, Vector3(x,5.05,-28.29),Vector3(0.26,0.045,0.035),Color(0.28,0.24,0.20))
 _landmark_part(landmark, Vector3(0,4.91,-28.22),Vector3(0.15,0.20,0.12),Color(0.45,0.36,0.25))
 _landmark_part(landmark, Vector3(0,4.75,-28.33),Vector3(0.28,0.035,0.025),Color(0.31,0.25,0.20))
 if str(get_meta("operation_id", "")) == "ngong_ping":
  var facility := preload("res://scripts/world/ngong_ping_secret_facility.gd").new() as NgongPingSecretFacility
  facility.name = "NgongPingSecretFacility"
  add_child(facility)
  facility.build(self)
 for x: float in [-30.0,-20.0,-12.0,12.0,20.0,30.0]:
  for z: float in [-33.0,-17.0,0.0,26.0,36.0]:
   if absf(x) < 17.5 and z < -20.0: continue # Keep the plinth clear.
   _box(Vector3(x,1.1,z),Vector3(0.45,2.2,0.45),Color(0.28,0.22,0.14))
   canopy_transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(3.0,2.7,3.0)),Vector3(x,2.7,z)))
   canopy_transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.9,1.8,1.9)),Vector3(x+0.8,3.45,z-0.4)))
 # Benches, visitor railings and path edging respect the landmark's public use.
 for z: float in [-16.0,-6.0,4.0,14.0,24.0]:
  for x: float in [-6.5,6.5]:
   _accent(Vector3(x,0.43,z),Vector3(1.8,0.12,0.65),Color(0.37,0.25,0.17))
   _accent(Vector3(x,0.22,z),Vector3(1.5,0.45,0.08),Color(0.27,0.27,0.23))
 for z: float in [-20.0,-12.0,-4.0,4.0,12.0,20.0,28.0]:
  for x: float in [-5.6,5.6]:
   _accent(Vector3(x,0.10,z),Vector3(0.12,0.18,7.5),Color(0.45,0.47,0.37))
 for x: float in [-9.0,9.0]:
  for z: float in [-18.0,-10.0,0.0,10.0,22.0]:
   _accent(Vector3(x,0.16,z),Vector3(0.9,0.32,0.9),Color(0.39,0.38,0.30))
   _accent(Vector3(x,0.70,z),Vector3(1.4,0.95,1.4),Color(0.23,0.39,0.23))
 # Distant, stylised peaks, and an atmospheric decorative cable-car vista.
 for x: float in [-39.0,-27.0,27.0,39.0]:
  _peak(Vector3(x,0,-42), 12.0, 15.0 + absf(x)*0.12, Color(0.27,0.37,0.35))
 _box(Vector3(0,8,30),Vector3(80,0.07,0.07),dark)
 for x: float in [-20.0,10.0,32.0]:
  _box(Vector3(x,6.3,30),Vector3(2.0,2.3,1.8),Color(0.66,0.26,0.18))
  _box(Vector3(x,6.6,29.08),Vector3(1.6,1.1,0.05),Color(0.30,0.46,0.48))
  _box(Vector3(x,7.8,30),Vector3(0.12,0.7,0.12),dark)

# A small fictional field office for the final operation, physically separate
# from the public monument and its viewing terrace.
func _mountain_field_office() -> void:
 var marker := Node3D.new()
 marker.name = "MountainFieldOffice"
 add_child(marker)
 var wall := Color(0.51,0.52,0.45)
 var trim := Color(0.26,0.31,0.27)
 for side: float in [-1.0,1.0]:
  _box(Vector3(9+side*2.5,1.6,5),Vector3(0.2,3.2,5.0),wall,true)
 _box(Vector3(9,1.6,7.5),Vector3(5.0,3.2,0.2),wall,true)
 # Two front wall panels leave a real, walkable two-metre entrance to the
 # separate field archive; the statue remains well away from this office.
 for side: float in [-1.0,1.0]:
  _box(Vector3(9+side*1.75,1.6,2.5),Vector3(1.5,3.2,0.2),wall,true)
 _box(Vector3(9,3.25,5),Vector3(5.2,0.16,5.2),trim,true)
 _box(Vector3(9,0.018,5),Vector3(4.9,0.036,4.9),Color(0.45,0.43,0.36))
 _box(Vector3(11.2,1.2,6.5),Vector3(0.12,1.8,1.3),Color(0.34,0.27,0.20))
 _sign("FIELD ARCHIVE", Vector3(9,2.7,7.35), 28)

# The pedestal is a stone shell around a central void. The rear aperture is
# part of a concealed maintenance seam, not a hole in the public-facing front.
func _buddha_plinth() -> void:
 var stone := Color(0.42,0.39,0.33)
 var cap := Color(0.64,0.53,0.36)
 for side: float in [-1.0,1.0]:
  _box(Vector3(side*10.25,1.2,-29),Vector3(13.5,2.4,18),stone,true)
  _box(Vector3(side*10.25,2.42,-29),Vector3(13.0,0.15,17.4),cap)
  _box(Vector3(side*2.72,1.2,-34),Vector3(1.55,2.4,8),stone,true)
 # The public/front apron remains broad and seamless.
 _box(Vector3(0,1.2,-24),Vector3(7.0,2.4,8.0),stone,true)
 _box(Vector3(0,2.42,-24),Vector3(7.0,0.15,8.0),cap)
 # A central shaft under the statue is open behind the sealed relief door.
 for z: float in [-20.1,-37.9]:
  if z > -30.0:
   _box(Vector3(0,2.42,z),Vector3(6.8,0.15,0.2),cap)
 for x: float in [-3.35,3.35]:
  _box(Vector3(x,2.42,-29),Vector3(0.2,0.15,17.5),cap)
 _box(Vector3(0,0.05,-20.0),Vector3(34,0.12,0.18),Color(0.39,0.34,0.28))
 _box(Vector3(0,0.05,-38.0),Vector3(3.8,0.12,0.18),Color(0.39,0.34,0.28),false)

# A broad physical approach to the public viewing terrace. The sloped
# collider backs the visible shallow steps and overlaps the existing plinth.
func _buddha_approach() -> void:
 var ramp := StaticBody3D.new()
 ramp.name = "BuddhaViewingApproach"
 # Shift the high end just beyond the leading edge of the plinth so the
 # capsule meets the terrace at floor height rather than hitting a vertical lip.
 ramp.position = Vector3(0,1.17,-17.45)
 ramp.rotation.x = atan(2.4 / 5.0)
 add_child(ramp)
 var shape := BoxShape3D.new()
 shape.size = Vector3(6.0,0.14,sqrt(2.4*2.4+5.0*5.0))
 var collider := CollisionShape3D.new()
 collider.shape = shape
 ramp.add_child(collider)
 for i: int in range(10):
  _box(Vector3(0, float(i)*0.24+0.03, -14.95-float(i)*0.5), Vector3(6.0,0.06,0.48), Color(0.61,0.57,0.48))
 for side: float in [-1.0,1.0]:
  _box(Vector3(side*3.15,0.65,-17.8),Vector3(0.15,1.3,5.4),Color(0.44,0.41,0.35))

func _landmark_part(parent: Node3D, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
 var visual := _sphere(pos, dimensions, color)
 visual.reparent(parent, false)
 # Original proportions are expressed around the model's seated base.
 visual.position = pos - Vector3(0,1.65,-29)
 return visual

func _sphere(pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
 var visual := MeshInstance3D.new()
 var mesh := SphereMesh.new()
 mesh.radius = 0.5
 mesh.height = 1.0
 mesh.radial_segments = 28
 mesh.rings = 16
 visual.mesh = mesh
 visual.scale = dimensions
 visual.position = pos
 var material := StandardMaterial3D.new()
 material.albedo_color = color
 material.roughness = 0.78
 material.metallic = 0.08
 visual.material_override = material
 add_child(visual)
 return visual

func _peak(pos: Vector3, radius: float, height: float, color: Color) -> void:
 var visual := MeshInstance3D.new()
 var mesh := CylinderMesh.new()
 mesh.top_radius = 0.0
 mesh.bottom_radius = radius
 mesh.height = height
 mesh.radial_segments = 7
 visual.mesh = mesh
 visual.position = pos + Vector3.UP * height * 0.5
 var material := StandardMaterial3D.new()
 material.albedo_color = color
 material.roughness = 1.0
 visual.material_override = material
 add_child(visual)
