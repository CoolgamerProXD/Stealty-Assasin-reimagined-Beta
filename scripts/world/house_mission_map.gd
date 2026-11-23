extends Node3D
## Compact original fictional safe-house block; not based on a commercial game or real address.
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
 # Front entry is a real gap between collidable wall returns.
 for x: float in [-7.5,7.5]:
  _box(Vector3(x,1.5,12),Vector3(7.0,3.0,0.35),plaster,true)
 _box(Vector3(0,2.8,12),Vector3(7.0,0.6,0.35),plaster,true)
 _box(Vector3(0,-0.05,14.0),Vector3(8.0,0.4,6.0),Color(0.36,0.34,0.31),true)
 _box(Vector3(-11,1.5,0),Vector3(0.35,3.0,24),plaster,true)
 _box(Vector3(11,1.5,0),Vector3(0.35,3.0,24),plaster,true)
 _box(Vector3(0,1.5,-12),Vector3(22,3.0,0.35),plaster,true)
 # A low internal divider and broad open doorway keep the compact route legible.
 for x: float in [-8.0,8.0]: _box(Vector3(x,1.25,-2.0),Vector3(6.0,2.5,0.28),plaster,true)
 _box(Vector3(-8.7,0.12,4),Vector3(2.2,0.24,2.0),trim)
 _box(Vector3(8.0,0.12,5),Vector3(2.0,0.24,2.2),trim)
 # Furnished living room: bench, low table, cabinet, plants, and warm window bays.
 _box(Vector3(-5,0.42,4.6),Vector3(3.4,0.55,0.95),Color(0.32,0.27,0.22))
 _box(Vector3(-5,0.84,4.20),Vector3(3.4,0.44,0.18),Color(0.25,0.22,0.19))
 _box(Vector3(-1.0,0.35,6.0),Vector3(1.5,0.12,0.9),Color(0.30,0.21,0.15))
 _box(Vector3(7.6,1.0,-7.0),Vector3(3.0,2.0,0.55),Color(0.29,0.22,0.16))
 for y: float in [0.55,1.05,1.55]: _box(Vector3(7.6,y,-6.70),Vector3(2.8,0.06,0.08),Color(0.63,0.54,0.40))
 for x: float in [-8.2,8.2]:
  _box(Vector3(x,1.8,11.75),Vector3(2.1,1.4,0.10),Color(0.18,0.35,0.39))
  _box(Vector3(x,2.55,11.68),Vector3(2.35,0.08,0.18),Color(0.62,0.43,0.25))
 # Restrained warm practicals illuminate the interior without hiding unfinished geometry.
 for x: float in [-6.0,0.0,6.0]:
  var light := OmniLight3D.new()
  light.position = Vector3(x,2.65,3.0 if x == 0.0 else -5.0)
  light.light_color = Color(1.0,0.74,0.49)
  light.light_energy = 0.55
  light.omni_range = 7.0
  light.shadow_enabled = false
  add_child(light)
 _box(Vector3(0,0.05,11.55),Vector3(3.1,0.1,0.32),Color(0.42,0.26,0.15))
 _box(Vector3(0,0.08,10.9),Vector3(0.12,0.06,0.5),Color(0.83,0.64,0.35))

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
