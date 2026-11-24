extends Node3D
## Compact original fictional safe-house block; not based on a commercial game or real address.
const SOFA := preload("res://assets/kenney_furniture/loungeSofaLong.glb")
const ARMCHAIR := preload("res://assets/kenney_furniture/loungeChair.glb")
const COFFEE_TABLE := preload("res://assets/kenney_furniture/tableCoffeeGlass.glb")
const DINING_CHAIR := preload("res://assets/kenney_furniture/chairCushion.glb")
const LAPTOP := preload("res://assets/kenney_furniture/laptop.glb")
const BOOKS := preload("res://assets/kenney_furniture/books.glb")
const PLANT := preload("res://assets/kenney_furniture/pottedPlant.glb")
var player: HotelPlayer
var npcs: Array[HotelNpc] = []
var hud: Label
var mesh_cache: Dictionary = {}
var material_cache: Dictionary = {}

func _ready() -> void:
 name = "HouseMissionMap"
 _room()
 var navigation := NavigationRegion3D.new()
 navigation.name = "HouseGuardNavigation"
 var navigation_mesh := NavigationMesh.new()
 navigation_mesh.vertices = PackedVector3Array([Vector3(-9,0,-10),Vector3(-9,0,10),Vector3(9,0,10),Vector3(9,0,-10)])
 navigation_mesh.add_polygon(PackedInt32Array([0,1,2,3]))
 navigation.navigation_mesh = navigation_mesh
 add_child(navigation)
 player = HotelPlayer.new()
 player.position = Vector3(0,0.05,8)
 add_child(player)
 hud = Label.new()
 hud.visible = false
 add_child(hud)

func _box(pos: Vector3, size: Vector3, color: Color, solid: bool = false) -> Node3D:
 var holder: Node3D = StaticBody3D.new() if solid else Node3D.new()
 holder.position = pos
 add_child(holder)
 var mesh_instance := MeshInstance3D.new()
 if not mesh_cache.has(size):
  var mesh := BoxMesh.new()
  mesh.size = size
  mesh_cache[size] = mesh
 mesh_instance.mesh = mesh_cache[size]
 if not material_cache.has(color):
  var material := StandardMaterial3D.new()
  material.albedo_color = color
  material.roughness = 0.88
  material_cache[color] = material
 mesh_instance.material_override = material_cache[color]
 holder.add_child(mesh_instance)
 if solid:
  var collision := CollisionShape3D.new()
  var shape := BoxShape3D.new()
  shape.size = size
  collision.shape = shape
  holder.add_child(collision)
 return holder

func _room() -> void:
 var floor := _box(Vector3(0,-0.25,0),Vector3(22,0.5,24),Color(0.47,0.39,0.31),true)
 _box(Vector3(0,3.2,0),Vector3(22,0.3,24),Color(0.19,0.23,0.24))
 var plaster := Color(0.58,0.53,0.44)
 var trim := Color(0.25,0.28,0.26)
 # Warm timber floorboards and a mineral-plaster interior separate surfaces by use.
 var floor_mesh := floor.get_child(0) as MeshInstance3D
 floor_mesh.material_override = StationMaterials.material(Color(0.47,0.39,0.31),"wood")
 # The front elevation is a constructed entry, not an eight-metre hole: wall
 # returns, a cased double door held open against the reveals, and a stone sill.
 for wall_center: float in [-7.5,7.5]:
  var window_center := -8.2 if wall_center < 0.0 else 8.2
  _box(Vector3(wall_center,0.50,12),Vector3(7.0,1.0,0.35),plaster,true)
  _box(Vector3(wall_center,2.76,12),Vector3(7.0,0.48,0.35),plaster,true)
  var wall_min := wall_center-3.5
  var wall_max := wall_center+3.5
  var window_min := window_center-1.05
  var window_max := window_center+1.05
  var left_pier_width := window_min-wall_min
  var right_pier_width := wall_max-window_max
  _box(Vector3((wall_min+window_min)*0.5,1.8,12),Vector3(left_pier_width,1.60,0.35),plaster,true)
  _box(Vector3((window_max+wall_max)*0.5,1.8,12),Vector3(right_pier_width,1.60,0.35),plaster,true)
 for x: float in [-2.8,2.8]: _box(Vector3(x,1.5,12),Vector3(2.4,3.0,0.35),plaster,true)
 _box(Vector3(0,2.8,12),Vector3(3.2,0.4,0.35),plaster,true)
 for x: float in [-1.62,1.62]: _box(Vector3(x,1.25,11.76),Vector3(0.16,2.5,0.34),Color(0.30,0.21,0.15))
 _box(Vector3(0,2.53,11.76),Vector3(3.4,0.16,0.34),Color(0.30,0.21,0.15))
 for side: float in [-1.0,1.0]:
  var open_leaf := _box(Vector3(side*1.35,1.10,11.48),Vector3(1.35,2.15,0.08),Color(0.39,0.27,0.19))
  open_leaf.rotation.y = PI*0.5
  _box(Vector3(side*1.48,1.1,11.40),Vector3(0.035,0.12,0.035),Color(0.77,0.61,0.35))
 _box(Vector3(0,0.045,12),Vector3(3.0,0.09,0.72),Color(0.48,0.44,0.36))
 _box(Vector3(0,-0.05,14.0),Vector3(8.0,0.4,6.0),Color(0.36,0.34,0.31),true)
 # A continuous skirting/cornice line, corner posts and room-to-room casings
 # give the compact safehouse real wall thickness and a human-scale rhythm.
 _box(Vector3(0,0.14,-11.72),Vector3(21.4,0.22,0.12),trim)
 _box(Vector3(0,3.04,-11.72),Vector3(21.4,0.16,0.14),Color(0.68,0.59,0.45))
 for side: float in [-1.0,1.0]:
  _box(Vector3(side*6.0,0.14,11.72),Vector3(9.3,0.22,0.12),trim)
  _box(Vector3(side*6.0,3.04,11.72),Vector3(9.3,0.16,0.14),Color(0.68,0.59,0.45))
 for x: float in [-10.72,10.72]:
  _box(Vector3(x,0.14,0),Vector3(0.12,0.22,23.4),trim)
  _box(Vector3(x,3.04,0),Vector3(0.14,0.16,23.4),Color(0.68,0.59,0.45))
 for boundary: float in [-8.0,8.0]:
  _box(Vector3(boundary,2.56,-2.0),Vector3(0.24,0.16,5.4),Color(0.31,0.29,0.25))
  for dz: float in [-4.65,0.65]: _box(Vector3(boundary,1.45,-2.0+dz),Vector3(0.24,2.9,0.16),Color(0.31,0.29,0.25))
 _box(Vector3(-11,1.5,0),Vector3(0.35,3.0,24),plaster,true)
 _box(Vector3(11,1.5,0),Vector3(0.35,3.0,24),plaster,true)
 _box(Vector3(0,1.5,-12),Vector3(22,3.0,0.35),plaster,true)
 # A low internal divider and broad open doorway keep the compact route legible.
 for x: float in [-8.0,8.0]: _box(Vector3(x,1.25,-2.0),Vector3(6.0,2.5,0.28),plaster,true)
 _box(Vector3(-8.7,0.12,4),Vector3(2.2,0.24,2.0),trim)
 _box(Vector3(8.0,0.12,5),Vector3(2.0,0.24,2.2),trim)
 # Two front windows sit in deep timber casings with sills, sash bars and a
 # modest internal shade rail; the glazing is a separate material layer.
 for x: float in [-8.2,8.2]:
  var glazing := _box(Vector3(x,1.8,11.75),Vector3(2.1,1.4,0.10),Color(0.20,0.46,0.50,0.28)) as Node3D
  glazing.name = "FrontWindowGlazing"
  (glazing.get_child(0) as MeshInstance3D).material_override = StationMaterials.material(Color(0.20,0.46,0.50,0.28),"glass")
  for side: float in [-1.0,1.0]: _box(Vector3(x+side*1.13,1.8,11.68),Vector3(0.12,1.62,0.16),Color(0.31,0.22,0.16))
  _box(Vector3(x,2.61,11.68),Vector3(2.36,0.13,0.16),Color(0.31,0.22,0.16))
  _box(Vector3(x,0.97,11.64),Vector3(2.40,0.15,0.38),Color(0.62,0.48,0.33))
  _box(Vector3(x,1.8,11.60),Vector3(0.06,1.30,0.09),Color(0.32,0.42,0.42))
  _box(Vector3(x,2.72,11.42),Vector3(2.55,0.10,0.10),Color(0.28,0.24,0.20))
 # Living room: proper upholstered seating and a low table grouped around a rug.
 _box(Vector3(-5.2,0.035,3.6),Vector3(6.6,0.05,4.2),Color(0.39,0.31,0.25))
 _place_asset(SOFA,"LivingRoomSofa",Vector3(-5.2,0,4.6),Vector3(0.49,0,0),Vector3(2.15,1.95,1.05),0.0)
 _place_asset(COFFEE_TABLE,"LivingRoomCoffeeTable",Vector3(-5.0,0,2.6),Vector3(-0.13,0,-0.10),Vector3(1.75,1.65,1.65),0.0)
 _place_asset(ARMCHAIR,"ReadingChair",Vector3(-8.2,0,2.4),Vector3(0.245,0,-0.205),Vector3(1.4,1.55,1.4),-PI/2.0)
 _place_asset(PLANT,"WindowPlant",Vector3(-9.4,0,7.0),Vector3.ZERO,Vector3(1.55,1.55,1.55),0.0)
 _place_asset(BOOKS,"CoffeeTableReading",Vector3(-4.4,0.48,2.72),Vector3(0.075,0,-0.047),Vector3(0.72,0.72,0.72),0.0)
 # Compact kitchen: plinths, cabinet fronts, worktop, backsplash, sink, mixer,
 # under-cabinet task light, cooker and a tall fridge; the aisle stays open.
 for x: float in [-3.5,-1.75,0.0,1.75,3.5]:
  _box(Vector3(x,0.48,-9.35),Vector3(1.68,0.94,1.45),Color(0.34,0.30,0.25))
  _box(Vector3(x,0.50,-8.60),Vector3(1.56,0.74,0.06),Color(0.45,0.38,0.30))
  _box(Vector3(x+0.55,0.52,-8.54),Vector3(0.045,0.18,0.035),Color(0.72,0.61,0.42))
 _box(Vector3(0,0.99,-9.36),Vector3(9.1,0.16,1.62),Color(0.64,0.59,0.49))
 _box(Vector3(0,1.65,-11.16),Vector3(8.6,1.25,0.35),Color(0.34,0.30,0.25))
 _box(Vector3(0,1.02,-8.55),Vector3(9.15,1.5,0.06),Color(0.42,0.52,0.50))
 _box(Vector3(-0.9,1.10,-9.10),Vector3(1.1,0.045,0.72),Color(0.28,0.34,0.35))
 _box(Vector3(-0.9,1.22,-9.18),Vector3(0.07,0.22,0.07),Color(0.63,0.69,0.65))
 _box(Vector3(-0.9,1.32,-9.37),Vector3(0.32,0.06,0.18),Color(0.63,0.69,0.65))
 for x: float in [2.4,3.05]: _box(Vector3(x,1.09,-9.2),Vector3(0.42,0.04,0.42),Color(0.14,0.17,0.18))
 _box(Vector3(5.3,1.25,-9.65),Vector3(1.45,2.5,1.55),Color(0.46,0.49,0.46),true)
 _box(Vector3(5.3,1.28,-8.86),Vector3(1.17,0.10,0.05),Color(0.24,0.33,0.34))
 _box(Vector3(5.3,1.73,-8.86),Vector3(1.17,0.10,0.05),Color(0.24,0.33,0.34))
 # Dining is a distinct shared-use zone, with chairs placed outside the main route.
 _box(Vector3(3.7,0.78,-3.5),Vector3(3.2,0.14,1.55),Color(0.34,0.24,0.17),true)
 for dx: float in [-1.35,1.35]:
  for dz: float in [-0.98,0.98]: _box(Vector3(3.7+dx,0.38,-3.5+dz),Vector3(0.12,0.76,0.12),Color(0.28,0.25,0.22))
 for x: float in [2.6,4.8]: _place_asset(DINING_CHAIR,"DiningChair",Vector3(x,0,-5.0),Vector3(0.10,0,-0.10),Vector3(1.25,1.25,1.25),PI)
 _place_asset(BOOKS,"KitchenPost",Vector3(3.1,0.86,-3.5),Vector3(0.075,0,-0.047),Vector3(0.62,0.62,0.62),0.0)
 # A small operations nook doubles as the safe-house's planning workstation.
 _box(Vector3(8.0,0.42,-5.0),Vector3(2.8,0.84,0.75),Color(0.27,0.22,0.18),true)
 _box(Vector3(8.0,0.88,-5.0),Vector3(3.0,0.12,0.90),Color(0.39,0.29,0.20))
 _place_asset(LAPTOP,"SafehousePlanningLaptop",Vector3(8.0,1.0,-5.0),Vector3(0.132,0,-0.12),Vector3(0.85,0.85,0.85),0.0)
 _place_asset(BOOKS,"SafehousePaperwork",Vector3(8.8,1.0,-5.0),Vector3(0.075,0,-0.047),Vector3(0.72,0.72,0.72),0.15)
 # Lockable storage, power outlets, a cable trunk and one maintained fire point.
 _box(Vector3(7.6,1.0,-7.0),Vector3(3.0,2.0,0.55),Color(0.29,0.22,0.16),true)
 for y: float in [0.55,1.05,1.55]: _box(Vector3(7.6,y,-6.70),Vector3(2.8,0.06,0.08),Color(0.63,0.54,0.40))
 _box(Vector3(10.60,1.4,-8.0),Vector3(0.12,2.8,0.14),Color(0.31,0.36,0.35))
 _box(Vector3(10.48,1.6,-7.4),Vector3(0.15,0.26,0.12),Color(0.82,0.66,0.40))
 _box(Vector3(-10.4,1.0,8.8),Vector3(0.42,1.9,0.38),Color(0.56,0.19,0.12))
 _box(Vector3(-10.4,2.03,8.8),Vector3(0.58,0.12,0.42),Color(0.68,0.61,0.50))
 _box(Vector3(-10.4,0.88,8.58),Vector3(0.24,0.38,0.05),Color(0.82,0.69,0.48))
 for x: float in [-8.2,8.2]:
  var glazing := _box(Vector3(x,1.8,11.75),Vector3(2.1,1.4,0.10),Color(0.20,0.46,0.50,0.28)) as Node3D
  (glazing.get_child(0) as MeshInstance3D).material_override = StationMaterials.material(Color(0.20,0.46,0.50,0.28),"glass")
  for side: float in [-1.0,1.0]: _box(Vector3(x+side*1.13,1.8,11.68),Vector3(0.12,1.62,0.16),Color(0.31,0.22,0.16))
  _box(Vector3(x,2.61,11.68),Vector3(2.36,0.13,0.16),Color(0.31,0.22,0.16))
  _box(Vector3(x,0.97,11.64),Vector3(2.40,0.15,0.38),Color(0.62,0.48,0.33))
  _box(Vector3(x,1.8,11.60),Vector3(0.06,1.30,0.09),Color(0.32,0.42,0.42))
  _box(Vector3(x,2.72,11.42),Vector3(2.55,0.10,0.10),Color(0.28,0.24,0.20))
 # Three ceiling coves and practicals establish warm pools without flattening the room.
 for x: float in [-6.0,0.0,6.0]:
  _box(Vector3(x,2.92,0),Vector3(0.18,0.12,15.0),Color(0.28,0.30,0.29))
  _box(Vector3(x,2.83,0),Vector3(1.2,0.06,5.2),Color(0.76,0.70,0.58))
  var light := OmniLight3D.new()
  light.position = Vector3(x,2.65,3.0 if x == 0.0 else -5.0)
  light.light_color = Color(1.0,0.74,0.49)
  light.light_energy = 0.55
  light.omni_range = 7.0
  light.shadow_enabled = false
  add_child(light)
 # Exposed conduit only on the service wall; access box is reachable at standing height.
 for run_y: float in [2.25,2.42]: _box(Vector3(10.76,run_y,-2.0),Vector3(0.08,0.08,12.0),Color(0.31,0.38,0.37))
 _box(Vector3(10.62,1.35,-2.0),Vector3(0.16,0.85,0.62),Color(0.22,0.29,0.30))
 _box(Vector3(10.52,1.55,-2.0),Vector3(0.04,0.10,0.25),Color(0.27,0.78,0.62))
 _box(Vector3(0,0.05,11.55),Vector3(3.1,0.1,0.32),Color(0.42,0.26,0.15))
 _box(Vector3(0,0.08,10.9),Vector3(0.12,0.06,0.5),Color(0.83,0.64,0.35))

func _place_asset(scene: PackedScene, node_name: String, at: Vector3, center_offset: Vector3, scale: Vector3, yaw: float) -> void:
 var placement := Node3D.new()
 placement.name = node_name+"Placement"
 placement.position = at
 placement.rotation.y = yaw
 add_child(placement)
 var model := scene.instantiate() as Node3D
 if model == null: return
 model.name = node_name
 model.scale = scale
 model.position = -center_offset*scale
 placement.add_child(model)

func _target(identity: String, role: String, start: Vector3, end: Vector3) -> HotelNpc:
 var profile := NpcProfile.new()
 profile.identity = identity
 profile.occupation = role
 profile.alertness = 0.4 if role == "security" else 0.2
 profile.schedule.append(ScheduleEntry.new(end,"working",5.0))
 profile.schedule.append(ScheduleEntry.new(start,"idle",4.0))
 var npc := HotelNpc.new()
 npc.profile = profile
 npc.position = start
 add_child(npc)
 npcs.append(npc)
 return npc
