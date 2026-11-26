class_name NgongPingSecretFacility
extends Node3D
## Original, collision-backed multi-level complex, authored inside and beneath
## the fictional monument. The public Buddha landmark remains a separate node;
## only its concealed rear service panel opens into this interconnected site.
const FLOORS_UNDER := [-3.2,-8.2,-13.2]
const FLOORS_INSIDE := [1.8,5.8,9.8,13.8,17.8]
const CORE_CENTER := Vector3(0.0,0.0,-29.0)
const OFFICE_CHAIR := preload("res://assets/kenney_furniture/chairCushion.glb")
const LAPTOP := preload("res://assets/kenney_furniture/laptop.glb")
const BOOKS := preload("res://assets/kenney_furniture/books.glb")
const CONSTRUCTION := preload("res://scripts/world/construction_kit.gd")
var world: Node3D
var player: HotelPlayer
var landmark: Node3D
var entry_open: bool = false
var entry_point: Vector3 = Vector3(0.0,0.55,-38.1)
var door_body: StaticBody3D
var door_collision: CollisionShape3D
var door_visual: MeshInstance3D
var elevator_lights: Array[OmniLight3D] = []
var discovered: bool = false
var mesh_cache: Dictionary = {}
var material_cache: Dictionary = {}
var statue_interior_nodes: Array[Node3D] = []

func build(parent_world: Node3D) -> void:
	world = parent_world
	name = "NgongPingSecretFacility"
	_build_hidden_entry()
	_build_underground_levels()
	_build_buddha_interior()
	_build_access_zones()
	_build_staff_routes()

func set_player_actor(actor: HotelPlayer, statue: Node3D) -> void:
	player = actor
	landmark = statue

func open_hidden_entry() -> bool:
	if entry_open: return false
	entry_open = true
	discovered = true
	if door_visual:
		var tween := create_tween()
		tween.tween_property(door_visual,"position:y",door_visual.position.y + 2.7,0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if door_collision: door_collision.set_deferred("disabled",true)
	for lamp: OmniLight3D in elevator_lights: lamp.visible = true
	return true

func set_discovered(value: bool) -> void:
	discovered = value
	if value and not entry_open:
		entry_open = true
		if door_visual: door_visual.visible = false
		if door_collision: door_collision.disabled = true
		for lamp: OmniLight3D in elevator_lights: lamp.visible = true

func is_inside_statue(point: Vector3) -> bool:
	return point.y > 1.0 and point.y < 22.5 and absf(point.x) < 8.5 and point.z > -36.0 and point.z < -22.0

func _process(_delta: float) -> void:
	if not landmark or not player: return
	var concealed_interior := is_inside_statue(player.global_position)
	landmark.visible = not concealed_interior
	# The inner floors, consoles and ribs are built in world space for play, but
	# must not cut through the public landmark silhouette from exterior views.
	# Reveal them only after the player crosses into the concealed statue volume.
	for interior_node: Node3D in statue_interior_nodes:
		if interior_node.visible != concealed_interior:
			interior_node.visible = concealed_interior

func _build_hidden_entry() -> void:
	# Carved bronze-and-stone frame is behind the seated figure, out of the public
	# approach view. The seam is intentionally subtle until the player examines it.
	_box("SealedMonumentDoorFrame",Vector3(-2.05,1.2,-38.03),Vector3(0.35,2.5,0.35),Color(0.35,0.30,0.22),true)
	_box("SealedMonumentDoorFrameRight",Vector3(2.05,1.2,-38.03),Vector3(0.35,2.5,0.35),Color(0.35,0.30,0.22),true)
	_box("SealedMonumentLintel",Vector3(0,2.42,-38.03),Vector3(4.45,0.28,0.35),Color(0.38,0.31,0.23),true)
	door_body = StaticBody3D.new()
	door_body.name = "ConcealedInteriorEntryDoor"
	door_body.position = Vector3(0,1.15,-38.0)
	add_child(door_body)
	var slab := BoxMesh.new()
	slab.size = Vector3(3.75,2.2,0.24)
	door_visual = MeshInstance3D.new()
	door_visual.name = "BronzeReliefPanel"
	door_visual.mesh = slab
	door_visual.position = Vector3(0,0,0)
	door_visual.material_override = _material(Color(0.40,0.34,0.25),0.88)
	door_body.add_child(door_visual)
	var relief := MeshInstance3D.new()
	var relief_mesh := BoxMesh.new()
	relief_mesh.size = Vector3(0.08,1.55,0.08)
	relief.mesh = relief_mesh
	relief.position = Vector3(0,0,0.16)
	relief.material_override = _material(Color(0.54,0.45,0.31),0.78)
	door_visual.add_child(relief)
	door_collision = CollisionShape3D.new()
	var door_shape := BoxShape3D.new()
	door_shape.size = Vector3(3.75,2.2,0.24)
	door_collision.shape = door_shape
	door_body.add_child(door_collision)
	# Descending concealed access ramp: 12 m long, 4.2 m below plaza level.
	var entry_angle := atan(3.2/12.0)
	var ramp := _box("SubstructureDescendingRamp",Vector3(0,-1.6,-44.0),Vector3(3.7,0.28,12.0),Color(0.39,0.37,0.32),true)
	ramp.rotation.x = -entry_angle
	for side: float in [-1.0,1.0]:
		var wall := _box("EntranceRampRetainingWall",Vector3(side*2.05,-1.6,-44.0),Vector3(0.24,3.2,12.0),Color(0.31,0.31,0.28),true)
		wall.rotation.x = -entry_angle
	var roof := _box("ConcealedRampCeiling",Vector3(0,2.5,-44.0),Vector3(4.5,0.24,12.0),Color(0.30,0.30,0.27),true)
	roof.rotation.x = -entry_angle
	for z: float in [-40.5,-43.0,-45.5,-48.0]:
		_box("EntryAmberGuide",Vector3(0,-0.3-(absf(z+44.0)*0.35),z),Vector3(2.6,0.045,0.06),Color(0.86,0.55,0.22))
	var light := OmniLight3D.new()
	light.name = "HiddenAccessGuideLight"
	light.position = Vector3(0,1.6,-42.0)
	light.light_color = Color(0.94,0.62,0.31)
	light.light_energy = 0.8
	light.omni_range = 10.0
	light.shadow_enabled = false
	light.visible = false
	add_child(light)
	elevator_lights.append(light)
	var door_hint := Label3D.new()
	door_hint.name = "ConcealedDoorHint"
	door_hint.text = "CARVED SEAM  /  EXAMINE"
	door_hint.position = Vector3(0,2.85,-38.3)
	door_hint.font_size = 19
	door_hint.pixel_size = 0.004
	door_hint.modulate = Color(0.78,0.70,0.55)
	add_child(door_hint)

func _build_underground_levels() -> void:
	for floor_index: int in range(FLOORS_UNDER.size()):
		var y: float = FLOORS_UNDER[floor_index]
		var palette: Color = [Color(0.30,0.34,0.34),Color(0.23,0.31,0.34),Color(0.27,0.30,0.32)][floor_index]
		_box("FacilitySlab_Sublevel_%d" % (floor_index+1),Vector3(0,y-0.18,-57),Vector3(60,0.36,50),palette,true)
		_build_level_shell(y,-57,60,50,5.0,palette)
		_add_navigation("SublevelNavigation_%d" % (floor_index+1),y+0.04,-80.0,-34.0,-28.0,28.0)
		_add_facility_zone(Rect2(-28.0,-80.0,56.0,46.0),y-0.3,y+1.0,["facility_staff","facility_research","facility_ops"][floor_index])
		_build_level_lighting(y,-57,palette)
	_build_room("SUBLEVEL 01  /  MONUMENTAL ACCESS HALL",Vector3(0,-3.0,-59),Vector2(25,12),Color(0.43,0.39,0.31),"ACCESS CONTROL",0)
	_build_room("SECURITY CHECKPOINT",Vector3(0,-3.0,-47),Vector2(18,8),Color(0.25,0.34,0.38),"IDENTITY / SCREENING",1)
	_build_room("ADMINISTRATIVE OFFICES",Vector3(-18,-3.0,-48),Vector2(17,11),Color(0.37,0.39,0.36),"ARCHIVE ADMIN",2)
	_build_room("STAFF QUARTERS",Vector3(18,-3.0,-69),Vector2(17,11),Color(0.38,0.34,0.29),"REST / ROTATION",3)
	_build_room("MAINTENANCE & STORAGE",Vector3(-18,-3.0,-69),Vector2(17,11),Color(0.34,0.36,0.34),"PLANT / STORAGE",4)
	_build_room("RESEARCH LABORATORIES",Vector3(-18,-8.0,-49),Vector2(18,12),Color(0.30,0.41,0.43),"RESEARCH / ANALYSIS",5)
	_build_room("SURVEILLANCE GALLERY",Vector3(18,-8.0,-49),Vector2(18,12),Color(0.24,0.34,0.40),"MONITOR / OBSERVE",6)
	_build_operations_chamber(Vector3(0,-8.0,-66))
	_build_room("SECRET MEETING SUITE",Vector3(18,-8.0,-70),Vector2(18,12),Color(0.38,0.34,0.30),"DIRECTORATE",7)
	_build_room("UNDERGROUND TRANSIT CONCOURSE",Vector3(0,-13.0,-47),Vector2(26,10),Color(0.25,0.35,0.38),"RESTRICTED TRANSIT",8)
	_build_room("ARCHIVE VAULT & STORAGE",Vector3(-18,-13.0,-67),Vector2(18,12),Color(0.32,0.34,0.35),"SEALED RECORDS",9)
	_build_room("PLANT / SERVICE BAY",Vector3(18,-13.0,-67),Vector2(18,12),Color(0.32,0.37,0.34),"POWER / AIR / SERVICE",10)
	_build_sublevel_connectors()

func _build_level_shell(floor_y: float, center_z: float, width: float, depth: float, height: float, tint: Color) -> void:
	var wall_color := tint.darkened(0.23)
	_box("SublevelNorthRetainingWall",Vector3(0,floor_y+height*0.5,center_z-depth*0.5),Vector3(width,height,0.36),wall_color,true)
	if is_equal_approx(floor_y,FLOORS_UNDER[0]):
		# The core ramp crosses the first sublevel's south wall; leave a real
		# central doorway rather than sealing the ramp behind the wall shell.
		var doorway_width := 3.8
		var side_width := (width-doorway_width)*0.5
		for side: float in [-1.0,1.0]:
			_box("SublevelSouthRetainingWall",Vector3(side*(doorway_width*0.5+side_width*0.5),floor_y+height*0.5,center_z+depth*0.5),Vector3(side_width,height,0.36),wall_color,true)
	else:
		_box("SublevelSouthRetainingWall",Vector3(0,floor_y+height*0.5,center_z+depth*0.5),Vector3(width,height,0.36),wall_color,true)
	_box("SublevelWestRetainingWall",Vector3(-width*0.5,floor_y+height*0.5,center_z),Vector3(0.36,height,depth),wall_color,true)
	_box("SublevelEastRetainingWall",Vector3(width*0.5,floor_y+height*0.5,center_z),Vector3(0.36,height,depth),wall_color,true)
	if is_equal_approx(floor_y,FLOORS_UNDER[0]):
		# Keep an overhead shaft clear above the descending exterior ramp and
		# the rising statue-core connector; a full-width ceiling would overlap
		# the player capsule and seal both ends of the concealed route.
		_box("SublevelCeiling",Vector3(-16.25,floor_y+height,center_z),Vector3(27.5,0.22,depth),tint.darkened(0.12),true)
		_box("SublevelCeiling",Vector3(16.25,floor_y+height,center_z),Vector3(27.5,0.22,depth),tint.darkened(0.12),true)
		_box("SublevelCeiling",Vector3(0,floor_y+height,-67.0),Vector3(width,0.22,30.0),tint.darkened(0.12),true)
		_box("SublevelCeiling",Vector3(0,floor_y+height,-30.5),Vector3(width,0.22,1.0),tint.darkened(0.12),true)
	else:
		_box("SublevelCeiling",Vector3(0,floor_y+height,center_z),Vector3(width,0.22,depth),tint.darkened(0.12),true)
	for x: float in [-width*0.5+0.5,width*0.5-0.5]:
		_box("SublevelStructuralRib",Vector3(x,floor_y+height*0.5,center_z),Vector3(0.38,height-0.2,depth-0.5),tint.lightened(0.09),true)
	for z: float in [center_z-depth*0.5+0.5,center_z+depth*0.5-0.5]:
		if is_equal_approx(floor_y,FLOORS_UNDER[0]) and z > center_z:
			var rib_doorway_width := 3.8
			var rib_side_width := (width-0.5-rib_doorway_width)*0.5
			for side: float in [-1.0,1.0]:
				_box("SublevelStructuralRib",Vector3(side*(rib_doorway_width*0.5+rib_side_width*0.5),floor_y+height*0.5,z),Vector3(rib_side_width,height-0.2,0.38),tint.lightened(0.09),true)
		else:
			_box("SublevelStructuralRib",Vector3(0,floor_y+height*0.5,z),Vector3(width-0.5,height-0.2,0.38),tint.lightened(0.09),true)

func _build_room(label: String, center: Vector3, span: Vector2, tint: Color, subtitle: String, style: int) -> void:
	var x := center.x
	var y := center.y
	var z := center.z
	var width := span.x
	var depth := span.y
	var h := 4.55
	var floor_y := y
	var wall := tint.darkened(0.22)
	# Room walls leave a broad, centered doorway in the south partition so the
	# facility's main circulation route never dead-ends at a decorative wall.
	_box("RoomWall",Vector3(x-width*0.5,y+h*0.5,z),Vector3(0.22,h,depth),wall,true)
	_box("RoomWall",Vector3(x+width*0.5,y+h*0.5,z),Vector3(0.22,h,depth),wall,true)
	_box("RoomWall",Vector3(x,y+h*0.5,z-depth*0.5),Vector3(width,h,0.22),wall,true)
	var doorway_width := 3.0
	var partition_width := (width-doorway_width)*0.5
	_box("RoomWallSouthLeft",Vector3(x-(doorway_width+partition_width)*0.5,y+h*0.5,z+depth*0.5),Vector3(partition_width,h,0.22),wall,true)
	_box("RoomWallSouthRight",Vector3(x+(doorway_width+partition_width)*0.5,y+h*0.5,z+depth*0.5),Vector3(partition_width,h,0.22),wall,true)
	_box("RoomThreshold",Vector3(x,y+0.04,z+depth*0.5),Vector3(2.4,0.08,0.8),Color(0.64,0.52,0.33))
	_box("RoomOverheadTrim",Vector3(x,y+4.15,z+depth*0.5+0.16),Vector3(3.5,0.12,0.16),Color(0.72,0.57,0.32))
	var sign := Label3D.new()
	sign.name = label.replace("  /  ","_").replace(" / ","_").replace(" ","_")
	sign.text = label + "\n" + subtitle
	sign.position = Vector3(x,y+3.55,z+depth*0.5+0.19)
	sign.font_size = 17
	sign.pixel_size = 0.004
	sign.modulate = Color(0.85,0.81,0.68)
	add_child(sign)
	_build_room_fitout(center,span,style,tint)
	# The entry is an actual framed opening with a recessed, powered sliding-door pocket.
	var entry_z := z+depth*0.5+0.12
	for side: float in [-1.0,1.0]:
		_box("DoorJamb",Vector3(x+side*1.58,y+2.08,entry_z),Vector3(0.15,4.12,0.28),Color(0.46,0.52,0.50))
		_box("SlidingDoorPocket",Vector3(x+side*1.94,y+2.05,entry_z-0.12),Vector3(0.58,3.78,0.14),Color(0.18,0.25,0.27))
	_box("DoorHeader",Vector3(x,y+4.14,entry_z),Vector3(3.31,0.18,0.28),Color(0.46,0.52,0.50))
	_box("DoorTrack",Vector3(x,y+4.27,entry_z-0.14),Vector3(2.94,0.055,0.15),Color(0.72,0.57,0.32))
	_box("ThresholdMetal",Vector3(x,y+0.09,z+depth*0.5),Vector3(2.9,0.11,0.68),Color(0.45,0.52,0.51))
	_box("DoorAccessReader",Vector3(x+1.82,y+1.35,entry_z+0.03),Vector3(0.12,0.42,0.08),Color(0.13,0.25,0.27))
	_box("DoorReaderStatus",Vector3(x+1.82,y+1.52,entry_z+0.08),Vector3(0.045,0.055,0.025),Color(0.28,0.82,0.70))
	# A distinctive sill and service access panel identify each room without
	# turning its modest, playable footprint into empty decorative volume.
	_box("RoomFloorInset",Vector3(x,y+0.025,z),Vector3(width-0.9,0.045,depth-0.9),tint.lightened(0.12))
	# Large-format stone/composite floor panels, a dark perimeter reveal, and
	# readable egress bands give the room an authored architectural floor rather
	# than a single colour plane. The flush inlay does not alter collision.
	for grid_x: float in range(-int(width*0.5)+2,int(width*0.5),2):
		_box("FloorPanelJoint",Vector3(x+grid_x,y+0.049,z),Vector3(0.018,0.006,depth-1.2),tint.darkened(0.15))
	for grid_z: float in range(-int(depth*0.5)+2,int(depth*0.5),2):
		_box("FloorPanelJoint",Vector3(x,y+0.049,z+grid_z),Vector3(width-1.2,0.006,0.018),tint.darkened(0.15))
	_box("FloorPerimeterReveal",Vector3(x,y+0.05,z-depth*0.5+0.65),Vector3(width-1.0,0.018,0.055),Color(0.12,0.20,0.22))
	_box("FloorPerimeterReveal",Vector3(x,y+0.05,z+depth*0.5-0.65),Vector3(width-1.0,0.018,0.055),Color(0.12,0.20,0.22))
	# Repeated wall bays, corner pilasters and a continuous service ceiling
	# articulate scale while leaving room entrances and NPC routes untouched.
	for side: float in [-1.0,1.0]:
		for dx: float in [-width*0.38,width*0.38]:
			_box("RoomStructuralPilaster",Vector3(x+dx,y+2.20,z+side*(depth*0.5-0.15)),Vector3(0.20,4.25,0.12),tint.lightened(0.14))
		for panel_x: float in [-width*0.25,0.0,width*0.25]:
			_box("RecessedWallPanel",Vector3(x+panel_x,y+2.65,z+side*(depth*0.5-0.13)),Vector3(width*0.19,1.45,0.055),tint.darkened(0.14))
			_box("WallPanelCap",Vector3(x+panel_x,y+3.43,z+side*(depth*0.5-0.08)),Vector3(width*0.19,0.055,0.075),tint.lightened(0.10))
	_box("CeilingServiceSpine",Vector3(x,y+h-0.17,z),Vector3(width-0.6,0.13,0.32),Color(0.13,0.20,0.22))
	_box("CeilingLightDiffuser",Vector3(x,y+h-0.265,z),Vector3(width*0.45,0.045,0.16),Color(0.62,0.79,0.77))
	_box("WallMountedAccessPanel",Vector3(x+width*0.5-0.32,y+1.35,z+depth*0.5-0.5),Vector3(0.12,1.0,0.55),Color(0.16,0.24,0.27))
	_box("DoorwayWayfindingStrip",Vector3(x,y+0.07,z+depth*0.5-0.54),Vector3(2.15,0.018,0.11),Color(0.86,0.58,0.24))
	# The interior gets a durable coved base, a separate ventilation branch,
	# service access and visible cable routing rather than a blank ceiling slab.
	_box("WallSkirting",Vector3(x,y+0.13,z-depth*0.5+0.18),Vector3(width-0.48,0.22,0.08),Color(0.21,0.28,0.30))
	_box("WallSkirtingSouthLeft",Vector3(x-width*0.25,y+0.13,z+depth*0.5-0.18),Vector3(width*0.5-1.8,0.22,0.08),Color(0.21,0.28,0.30))
	_box("WallSkirtingSouthRight",Vector3(x+width*0.25,y+0.13,z+depth*0.5-0.18),Vector3(width*0.5-1.8,0.22,0.08),Color(0.21,0.28,0.30))
	for side: float in [-1.0,1.0]:
		_box("WallSkirting",Vector3(x+side*(width*0.5-0.17),y+0.13,z),Vector3(0.08,0.22,depth-0.5),Color(0.21,0.28,0.30))
	_box("SupplyDuct",Vector3(x-width*0.30,y+h-0.36,z-depth*0.22),Vector3(0.48,0.42,depth*0.48),Color(0.35,0.42,0.43))
	_box("ReturnAirGrille",Vector3(x+width*0.5-0.18,y+h-0.8,z-depth*0.5+0.24),Vector3(0.06,0.72,1.75),Color(0.18,0.26,0.28))
	for grille: float in [-0.28,-0.09,0.10,0.29]:
		_box("ReturnAirGrilleSlat",Vector3(x+width*0.5-0.13,y+h-0.8+grille,z-depth*0.5+0.24),Vector3(0.055,0.035,1.62),Color(0.53,0.60,0.58))
	_box("ConduitTrunk",Vector3(x-width*0.5+0.38,y+h-0.58,z),Vector3(0.10,0.10,depth-0.6),Color(0.25,0.34,0.35))
	_box("JunctionBox",Vector3(x-width*0.5+0.40,y+2.45,z+depth*0.5-0.65),Vector3(0.25,0.34,0.17),Color(0.36,0.45,0.45))
	_box("EmergencyFixture",Vector3(x-1.0,y+3.87,z+depth*0.5+0.10),Vector3(0.68,0.20,0.10),Color(0.76,0.27,0.18))

func _build_room_fitout(center: Vector3, span: Vector2, style: int, tint: Color) -> void:
	var x := center.x
	var y := center.y
	var z := center.z
	var width := span.x
	var depth := span.y
	match style:
		0:
			# Monument access: staffed reception desks, queue lanes and baggage scan.
			_build_workstation(center,Vector3(-8.0,0.0,-3.5),tint)
			_build_workstation(center,Vector3(8.0,0.0,-3.5),tint)
			_box("XrayBaggageConveyor",Vector3(x,y+0.55,z-4.0),Vector3(4.8,1.1,1.15),Color(0.18,0.25,0.27),true)
			_box("BaggageScannerBelt",Vector3(x,y+1.12,z-4.0),Vector3(4.4,0.08,0.95),Color(0.22,0.34,0.36))
			for lane_x: float in [-4.6,4.6]:
				for side: float in [-1.0,1.0]: _box("AccessLanePost",Vector3(x+lane_x+side*0.78,y+1.05,z-2.25),Vector3(0.12,2.1,0.12),Color(0.25,0.34,0.35))
				_box("AccessLaneHeader",Vector3(x+lane_x,y+2.1,z-2.25),Vector3(1.68,0.12,0.12),Color(0.47,0.58,0.56))
				_box("AccessLaneStatus",Vector3(x+lane_x,y+1.95,z-2.16),Vector3(0.32,0.035,0.025),Color(0.28,0.82,0.70))
			_box("SecureAccessCabinet",Vector3(x+width*0.5-1.0,y+1.0,z-depth*0.5+1.1),Vector3(0.9,2.0,0.75),Color(0.18,0.25,0.27),true)
		1:
			# Screening room: an operator desk and two clear scan lanes.
			_build_workstation(center,Vector3(-5.8,0.0,-2.3),tint)
			_build_workstation(center,Vector3(5.8,0.0,-2.3),tint)
			for lane_x: float in [-3.3,3.3]:
				_box("WalkThroughScannerBase",Vector3(x+lane_x,y+0.14,z-2.55),Vector3(1.48,0.28,0.72),Color(0.17,0.25,0.27))
				for side: float in [-1.0,1.0]: _box("WalkThroughScannerUpright",Vector3(x+lane_x+side*0.61,y+1.23,z-2.55),Vector3(0.12,2.18,0.16),Color(0.39,0.48,0.48))
				_box("WalkThroughScannerCrossbar",Vector3(x+lane_x,y+2.35,z-2.55),Vector3(1.34,0.12,0.16),Color(0.39,0.48,0.48))
				_box("ScannerStatusDisplay",Vector3(x+lane_x,y+2.23,z-2.44),Vector3(0.46,0.16,0.035),Color(0.22,0.76,0.69))
			_box("ScreeningTrayStack",Vector3(x,y+0.48,z-depth*0.5+0.85),Vector3(2.2,0.85,0.62),Color(0.24,0.31,0.32),true)
		2:
			# Records administration: two individual workstations and locked files.
			for dx: float in [-4.6,4.6]: _build_workstation(center,Vector3(dx,0.0,-2.25),tint)
			for dx: float in [-7.0,7.0]:
				_box("RecordsCabinet",Vector3(x+dx,y+1.15,z-depth*0.5+1.05),Vector3(1.18,2.3,1.2),Color(0.23,0.31,0.32),true)
				for shelf_y: float in [0.42,0.98,1.54,2.10]: _box("FileDrawerPull",Vector3(x+dx,y+shelf_y,z-depth*0.5+0.42),Vector3(0.62,0.045,0.035),Color(0.68,0.55,0.34))
			_place_kenney(BOOKS,"IntakeFiles",Vector3(x-4.0,y+0.88,z-2.4),Vector3(0.075,0.0,-0.047),Vector3(0.8,0.8,0.8),0.12)
		3:
			# Staff quarters: two made-up bunks, personal lockers and a shared table.
			for dx: float in [-4.4,4.4]: _build_bunk(center,dx,-2.8,tint)
			for dx: float in [-7.2,7.2]:
				_box("StaffLocker",Vector3(x+dx,y+1.15,z-2.35),Vector3(1.25,2.3,1.25),Color(0.22,0.31,0.32),true)
				_box("LockerVent",Vector3(x+dx,y+1.8,z-1.69),Vector3(0.50,0.32,0.035),Color(0.47,0.57,0.55))
			_box("QuartersTable",Vector3(x,y+0.78,z+2.8),Vector3(2.8,0.12,1.0),Color(0.29,0.20,0.15),true)
			for dx: float in [-1.0,1.0]: _box("TableLeg",Vector3(x+dx,y+0.39,z+2.8),Vector3(0.10,0.78,0.10),Color(0.23,0.28,0.28))
			_place_kenney(BOOKS,"StaffReading",Vector3(x+0.45,y+0.88,z+2.72),Vector3(0.075,0.0,-0.047),Vector3(0.7,0.7,0.7),-0.12)
		4:
			# Maintenance and storage: service racks flank a clear working aisle.
			for dx: float in [-6.0,6.0]: _build_storage_rack(center,dx,-2.8,2.5)
			_box("PortableGenerator",Vector3(x,y+0.78,z-depth*0.5+1.05),Vector3(2.3,1.55,1.35),Color(0.30,0.35,0.34),true)
			_box("GeneratorServicePanel",Vector3(x,y+0.95,z-depth*0.5+0.34),Vector3(1.05,0.58,0.08),Color(0.15,0.25,0.27))
			for dx: float in [-0.36,-0.12,0.12,0.36]: _box("GeneratorVent",Vector3(x+dx,y+0.95,z-depth*0.5+0.29),Vector3(0.035,0.44,0.03),Color(0.50,0.58,0.56))
			_box("MaintenanceBench",Vector3(x,y+0.91,z+2.8),Vector3(4.8,0.14,0.86),Color(0.27,0.22,0.17),true)
			for dx: float in [-2.2,2.2]: _box("BenchLeg",Vector3(x+dx,y+0.45,z+2.8),Vector3(0.12,0.9,0.12),Color(0.20,0.28,0.30))
		5:
			# Research: washable bench tops, sink bays, cabinets and observation hoods.
			for dx: float in [-5.1,5.1]:
				_box("ResearchBenchCabinet",Vector3(x+dx,y+0.50,z-depth*0.5+2.1),Vector3(4.2,1.0,1.25),Color(0.22,0.31,0.32),true)
				_box("ResearchBenchTop",Vector3(x+dx,y+1.08,z-depth*0.5+2.1),Vector3(4.45,0.14,1.42),Color(0.58,0.62,0.57))
				_box("FumeHoodBack",Vector3(x+dx,y+2.1,z-depth*0.5+1.55),Vector3(3.6,1.85,0.14),Color(0.23,0.37,0.39))
				_box("FumeHoodSash",Vector3(x+dx,y+2.05,z-depth*0.5+1.45),Vector3(2.9,0.12,0.12),Color(0.67,0.72,0.66))
				_box("LabInstrument",Vector3(x+dx-1.1,y+1.42,z-depth*0.5+2.05),Vector3(0.55,0.48,0.5),Color(0.19,0.28,0.31))
				_box("LabInstrumentScreen",Vector3(x+dx-1.1,y+1.72,z-depth*0.5+1.78),Vector3(0.34,0.20,0.04),Color(0.22,0.76,0.70))
				_box("SpecimenTray",Vector3(x+dx+0.9,y+1.19,z-depth*0.5+2.15),Vector3(0.75,0.10,0.42),Color(0.68,0.60,0.43))
				_box("LabStorageCabinet",Vector3(x+dx,y+3.15,z-depth*0.5+0.44),Vector3(2.6,1.5,0.32),Color(0.20,0.30,0.32),true)
		6:
			# Surveillance gallery: operator benches face a dedicated display wall.
			for dx: float in [-6.0,-3.0,0.0,3.0,6.0]:
				_build_workstation(center,Vector3(dx,0.0,-2.8),tint)
				_box("CameraFeedLabelStrip",Vector3(x+dx,y+2.45,z-depth*0.5+0.24),Vector3(2.1,0.10,0.07),Color(0.72,0.55,0.32))
		7:
			# Directorate suite: deliberate briefing table with seating and wall display.
			_box("BriefingTableTop",Vector3(x,y+0.82,z-3.15),Vector3(6.2,0.16,2.2),Color(0.34,0.25,0.18),true)
			for dx: float in [-2.7,2.7]:
				for dz: float in [-3.8,-2.5]: _box("BriefingTablePedestal",Vector3(x+dx,y+0.40,z+dz),Vector3(0.18,0.8,0.18),Color(0.25,0.30,0.30))
			for dx: float in [-4.3,-1.4,1.4,4.3]:
				_place_kenney(OFFICE_CHAIR,"BriefingChair",Vector3(x+dx,y,z-1.6),Vector3(0.10,0.0,-0.10),Vector3(1.3,1.3,1.3),PI)
			_box("DirectorateBriefingDisplay",Vector3(x,y+2.7,z-depth*0.5+0.18),Vector3(4.6,1.55,0.08),Color(0.12,0.31,0.35))
			_box("DirectorateWallChart",Vector3(x+5.3,y+2.4,z-depth*0.5+0.18),Vector3(2.1,1.0,0.08),Color(0.51,0.45,0.35))
		8:
			# Restricted transit: benches and dispatch panels line the sides.
			for dx: float in [-9.0,9.0]:
				_box("TransitBenchSeat",Vector3(x+dx,y+0.56,z-2.5),Vector3(3.8,0.16,0.68),Color(0.29,0.37,0.38),true)
				_box("TransitBenchBack",Vector3(x+dx,y+1.18,z-2.82),Vector3(3.8,1.1,0.14),Color(0.25,0.34,0.35))
				for side: float in [-1.0,1.0]: _box("TransitBenchLeg",Vector3(x+dx+side*1.55,y+0.25,z-2.5),Vector3(0.12,0.5,0.55),Color(0.22,0.28,0.29))
			for dx: float in [-9.0,9.0]: _box("TransitRouteBoard",Vector3(x+dx,y+2.65,z-depth*0.5+0.17),Vector3(3.2,1.3,0.08),Color(0.12,0.30,0.34))
		9:
			# Archive vault: secure compact shelving, inventory table and records.
			for dx: float in [-6.4,6.4]: _build_storage_rack(center,dx,-2.9,3.1)
			_box("ArchiveInventoryTable",Vector3(x,y+0.82,z-depth*0.5+1.45),Vector3(3.8,0.14,1.35),Color(0.27,0.20,0.15),true)
			_place_kenney(BOOKS,"ArchiveRegister",Vector3(x,y+0.90,z-depth*0.5+1.35),Vector3(0.075,0.0,-0.047),Vector3(0.8,0.8,0.8),0.0)
			for dx: float in [-1.35,1.35]: _box("VaultDoorBolt",Vector3(x+dx,y+1.6,z-depth*0.5+0.2),Vector3(0.12,1.8,0.14),Color(0.43,0.50,0.49))
		10:
			# Plant room: pumps, isolation valves and an electrical distribution board.
			for dx: float in [-5.0,5.0]:
				_box("AirHandlingUnit",Vector3(x+dx,y+1.4,z-depth*0.5+1.2),Vector3(3.4,2.8,2.4),Color(0.24,0.33,0.34),true)
				for vent: float in [-0.8,-0.4,0.0,0.4,0.8]: _box("AirUnitLouvre",Vector3(x+dx+vent,y+1.35,z-depth*0.5-0.04),Vector3(0.12,1.7,0.05),Color(0.48,0.56,0.54))
				_box("AirUnitServicePlate",Vector3(x+dx,y+1.1,z-depth*0.5-0.08),Vector3(0.62,0.42,0.04),Color(0.13,0.26,0.28))
				_box("AirUnitStatus",Vector3(x+dx+0.20,y+1.26,z-depth*0.5-0.12),Vector3(0.08,0.08,0.03),Color(0.22,0.82,0.67))
			_box("DistributionBoard",Vector3(x,y+1.65,z-depth*0.5+0.24),Vector3(3.2,3.3,0.24),Color(0.18,0.27,0.29),true)
			for dx: float in [-1.0,0.0,1.0]:
				_box("BreakerHandle",Vector3(x+dx,y+1.72,z-depth*0.5+0.08),Vector3(0.16,0.38,0.04),Color(0.68,0.56,0.34))
				_box("BreakerStatus",Vector3(x+dx,y+2.18,z-depth*0.5+0.08),Vector3(0.10,0.10,0.035),Color(0.26,0.80,0.65))
			for riser_y: float in [1.35,2.2,3.05]:
				_box("PlantPipeRun",Vector3(x+width*0.5-0.48,y+riser_y,z),Vector3(0.18,0.16,depth-1.0),Color(0.52,0.58,0.55))
			for pipe_y: float in [1.3,1.65,2.0]:
				_box("PlantPipeRiser",Vector3(x+width*0.5-0.48,y+2.25,z+depth*0.5-0.85),Vector3(0.16,2.0,0.16),Color(0.52,0.58,0.55))
				_box("IsolationValve",Vector3(x+width*0.5-0.48,y+pipe_y,z+depth*0.5-0.85),Vector3(0.52,0.08,0.08),Color(0.73,0.49,0.26))

func _build_workstation(center: Vector3, offset: Vector3, tint: Color) -> void:
	var desk := center+offset
	var wood := Color(0.34,0.25,0.18)
	var dark_metal := Color(0.16,0.23,0.25)
	_box("DeskPedestal",desk+Vector3(-0.78,0.40,0.0),Vector3(0.50,0.80,0.72),dark_metal,true)
	for dx: float in [-0.92,0.92]:
		for dz: float in [-0.28,0.28]: _box("DeskLeg",desk+Vector3(dx,0.37,dz),Vector3(0.08,0.74,0.08),dark_metal)
	_box("DeskWorktopWood",desk+Vector3(0.0,0.78,0.0),Vector3(2.10,0.13,0.92),wood,true)
	_box("DeskEdgeBand",desk+Vector3(0.0,0.70,0.0),Vector3(2.13,0.05,0.95),Color(0.48,0.38,0.27))
	_box("MonitorHousing",desk+Vector3(0.0,1.19,-0.30),Vector3(0.78,0.52,0.075),Color(0.13,0.19,0.21))
	_box("MonitorDisplay",desk+Vector3(0.0,1.20,-0.255),Vector3(0.67,0.40,0.018),Color(0.16,0.55,0.60))
	_box("MonitorStand",desk+Vector3(0.0,0.93,-0.28),Vector3(0.12,0.22,0.10),dark_metal)
	_box("Keyboard",desk+Vector3(0.0,0.87,0.12),Vector3(0.52,0.035,0.18),Color(0.27,0.32,0.32))
	_place_kenney(LAPTOP,"OpenLaptop",desk+Vector3(0.60,0.84,0.12),Vector3(0.132,0.0,-0.12),Vector3(0.65,0.65,0.65),-0.08)
	_place_kenney(OFFICE_CHAIR,"WorkChair",desk+Vector3(0.0,0.0,1.10),Vector3(0.10,0.0,-0.10),Vector3(1.3,1.3,1.3),PI)
	_box("DeskCableGrommet",desk+Vector3(-0.86,0.85,-0.32),Vector3(0.12,0.035,0.12),Color(0.20,0.28,0.29))

func _build_bunk(center: Vector3, dx: float, dz: float, tint: Color) -> void:
	var p := center+Vector3(dx,0.0,dz)
	for side: float in [-1.0,1.0]:
		_box("BunkFramePost",p+Vector3(side*0.78,0.84,-0.34),Vector3(0.12,1.68,0.12),Color(0.28,0.35,0.36))
		_box("BunkFramePost",p+Vector3(side*0.78,0.84,0.34),Vector3(0.12,1.68,0.12),Color(0.28,0.35,0.36))
		_box("BunkRail",p+Vector3(side*0.78,1.46,0.0),Vector3(0.12,0.20,0.88),Color(0.33,0.41,0.41))
	_box("LowerBunkBase",p+Vector3(0.0,0.20,0.0),Vector3(1.55,0.30,0.92),Color(0.25,0.32,0.33),true)
	_box("LowerBunkMattress",p+Vector3(0.0,0.43,0.0),Vector3(1.43,0.20,0.80),Color(0.47,0.51,0.47))
	_box("LowerBunkCover",p+Vector3(0.0,0.56,0.12),Vector3(1.40,0.08,0.52),Color(0.31,0.41,0.41))
	_box("UpperBunkBase",p+Vector3(0.0,1.12,0.0),Vector3(1.55,0.25,0.92),Color(0.25,0.32,0.33),true)
	_box("UpperBunkMattress",p+Vector3(0.0,1.30,0.0),Vector3(1.43,0.16,0.80),Color(0.47,0.51,0.47))
	_box("UpperBunkPillow",p+Vector3(0.0,1.40,-0.28),Vector3(0.52,0.10,0.24),Color(0.71,0.69,0.61))
	_box("BunkLadderSide",p+Vector3(0.94,0.67,0.0),Vector3(0.06,1.25,0.07),Color(0.33,0.41,0.41))
	for rung_y: float in [0.25,0.62,0.99,1.36]: _box("BunkLadderRung",p+Vector3(0.94,rung_y,0.0),Vector3(0.08,0.06,0.75),Color(0.43,0.49,0.46))

func _build_storage_rack(center: Vector3, dx: float, dz: float, width: float) -> void:
	var p := center+Vector3(dx,0.0,dz)
	for side: float in [-1.0,1.0]: _box("StorageRackUpright",p+Vector3(side*width*0.5,1.65,0.0),Vector3(0.08,3.3,0.10),Color(0.31,0.40,0.41))
	for shelf_y: float in [0.45,1.25,2.05,2.85]:
		_box("StorageRackShelf",p+Vector3(0.0,shelf_y,0.0),Vector3(width,0.10,0.8),Color(0.34,0.42,0.41))
		_box("StorageBox",p+Vector3(-width*0.24,shelf_y+0.24,0.0),Vector3(0.58,0.42,0.62),Color(0.43,0.38,0.29))
		_box("StorageCase",p+Vector3(width*0.23,shelf_y+0.28,0.04),Vector3(0.62,0.48,0.58),Color(0.24,0.34,0.35))
	_box("RackInventoryTag",p+Vector3(0.0,3.08,-0.43),Vector3(0.62,0.20,0.035),Color(0.76,0.66,0.48))

func _place_kenney(scene: PackedScene, node_name: String, at: Vector3, center_offset: Vector3, scale: Vector3, yaw: float) -> void:
	var root_node := Node3D.new()
	root_node.name = node_name+"Placement"
	root_node.position = at
	root_node.rotation.y = yaw
	add_child(root_node)
	var model := scene.instantiate() as Node3D
	if not model: return
	model.name = node_name
	model.scale = scale
	model.position = -center_offset*scale
	root_node.add_child(model)

func _build_operations_chamber(center: Vector3) -> void:
	var x := center.x
	var y := center.y
	var z := center.z
	var shell_height := 4.45
	var shell_y := y + shell_height * 0.5
	var shell_color := Color(0.34,0.40,0.40)
	var wall_color := Color(0.23,0.31,0.33)
	# Operations occupies an enclosed, purpose-built room inside the larger
	# sublevel, with an actual door opening to the transit aisle. This keeps the
	# room's functions legible instead of leaving its consoles on an empty slab.
	_box("OperationsWestWall",Vector3(x-17.5,shell_y,z),Vector3(0.28,shell_height,20.8),shell_color,true)
	_box("OperationsEastWall",Vector3(x+17.5,shell_y,z),Vector3(0.28,shell_height,20.8),shell_color,true)
	_box("OperationsNorthWall",Vector3(x,shell_y,z-10.4),Vector3(35.0,shell_height,0.28),shell_color,true)
	for side: float in [-1.0,1.0]:
		_box("OperationsSouthWall",Vector3(x+side*10.35,shell_y,z+10.4),Vector3(14.3,shell_height,0.28),shell_color,true)
		_box("OperationsPortalJamb",Vector3(x+side*3.2,y+2.05,z+10.4),Vector3(0.22,4.1,0.34),wall_color)
	_box("OperationsPortalHeader",Vector3(x,y+4.22,z+10.4),Vector3(6.2,0.18,0.34),wall_color)
	_box("OperationsPortalTrack",Vector3(x,y+4.34,z+10.18),Vector3(5.7,0.06,0.16),Color(0.73,0.57,0.31))
	# The heavy structural piers, wall panels, and service risers express load
	# paths and maintenance access; the clear central axis remains unobstructed.
	for side: float in [-1.0,1.0]:
		for bay_z: float in [-8.8,-3.0,3.0,8.8]:
			_box("OperationsStructuralPier",Vector3(x+side*16.9,y+2.12,z+bay_z),Vector3(0.52,4.22,0.64),wall_color,true)
			_box("OperationsPierBase",Vector3(x+side*16.78,y+0.30,z+bay_z),Vector3(0.72,0.20,0.78),Color(0.48,0.53,0.48))
		_box("OperationsServiceRun",Vector3(x+side*16.55,y+3.54,z),Vector3(0.10,0.10,17.5),Color(0.48,0.56,0.54))
		for service_z: float in [-7.0,4.8]:
			CONSTRUCTION.service_riser(self,"OperationsServiceRiser",Vector3(x+side*16.72,y+0.1,z+service_z),3.8,Color(0.66,0.57,0.40),wall_color,3)
	for bay_x: float in [-12.0,-6.0,0.0,6.0,12.0]:
		_box("OperationsNorthWallRecess",Vector3(x+bay_x,y+2.54,z-10.23),Vector3(4.85,2.55,0.06),wall_color)
		_box("OperationsWallPanelCap",Vector3(x+bay_x,y+3.86,z-10.17),Vector3(4.85,0.08,0.10),Color(0.51,0.61,0.58))
	_box("CentralOperationsFloor",Vector3(x,y+0.03,z),Vector3(35,0.10,21),Color(0.40,0.45,0.44))
	_box("CommandTableBase",Vector3(x,y+0.83,z),Vector3(9.0,1.45,4.5),Color(0.31,0.39,0.39),true)
	_box("CommandTableTopPanel",Vector3(x,y+1.61,z),Vector3(9.18,0.12,4.68),Color(0.50,0.57,0.52))
	_box("CommandTableDisplayMap",Vector3(x,y+1.70,z),Vector3(8.4,0.08,4.0),Color(0.24,0.62,0.62))
	for grid_x: float in [-3.0,-1.5,0.0,1.5,3.0]: _box("CommandMapGridLine",Vector3(x+grid_x,y+1.747,z),Vector3(0.025,0.012,3.72),Color(0.60,0.78,0.68))
	for grid_z: float in [-1.35,0.0,1.35]: _box("CommandMapGridLine",Vector3(x,y+1.75,z+grid_z),Vector3(8.0,0.012,0.025),Color(0.60,0.78,0.68))
	for side: float in [-1.0,1.0]:
		for chair_z: float in [-1.65,1.65]: _place_kenney(OFFICE_CHAIR,"OperationsBriefingChair",Vector3(x+side*5.35,y,z+chair_z),Vector3(0.10,0.0,-0.10),Vector3(1.3,1.3,1.3),PI*0.5 if side < 0.0 else -PI*0.5)
	for side: float in [-1.0,1.0]:
		for i: int in range(5):
			var desk_x := x+side*12.0
			var desk_z := z-6.2+float(i)*3.0
			_box("OperationsConsole",Vector3(desk_x,y+0.50,desk_z),Vector3(4.1,0.98,1.5),Color(0.31,0.39,0.39),true)
			_box("OperationsConsoleTopPanel",Vector3(desk_x,y+1.03,desk_z),Vector3(4.22,0.12,1.62),Color(0.50,0.56,0.51))
			_box("OperationsDisplay",Vector3(desk_x,y+1.62,desk_z-0.38),Vector3(1.75,1.05,0.08),Color(0.13,0.49,0.55))
			_box("OperationsDisplayBezel",Vector3(desk_x,y+1.62,desk_z-0.425),Vector3(1.88,1.18,0.05),Color(0.16,0.23,0.25))
			_box("OperationsKeyboard",Vector3(desk_x,y+1.12,desk_z+0.28),Vector3(1.18,0.045,0.32),Color(0.19,0.27,0.28))
			_box("OperationsStatusRail",Vector3(desk_x,y+1.11,desk_z-0.55),Vector3(1.25,0.045,0.06),Color(0.26,0.78,0.68))
			_box("OperationsSecondaryDisplay",Vector3(desk_x+0.88,y+1.43,desk_z-0.35),Vector3(0.72,0.56,0.055),Color(0.17,0.48,0.54))
			_box("OperationsSecondaryBezel",Vector3(desk_x+0.88,y+1.43,desk_z-0.39),Vector3(0.82,0.66,0.045),Color(0.16,0.23,0.25))
			_box("OperationsPaperLog",Vector3(desk_x-1.20,y+1.14,desk_z+0.26),Vector3(0.58,0.035,0.42),Color(0.78,0.73,0.61))
			_box("OperationsDeskPhone",Vector3(desk_x-1.48,y+1.13,desk_z-0.48),Vector3(0.32,0.08,0.28),Color(0.18,0.26,0.27))
			_box("OperationsRadioStatus",Vector3(desk_x-1.48,y+1.20,desk_z-0.48),Vector3(0.06,0.03,0.18),Color(0.86,0.54,0.22))
			_place_kenney(OFFICE_CHAIR,"OperationsConsoleChair",Vector3(desk_x,y,desk_z+1.62),Vector3(0.10,0.0,-0.10),Vector3(1.25,1.25,1.25),PI)
	for i: int in range(7):
		_box("WallOfOperationsScreens",Vector3(x-9.0+float(i)*3.0,y+3.35,z-10.1),Vector3(2.5,1.8,0.12),Color(0.13,0.35,0.41))
	var label := Label3D.new()
	label.text = "BLACKLINE  /  CENTRAL OPERATIONS"
	label.position = Vector3(x,y+4.05,z-10.15)
	label.font_size = 23
	label.pixel_size = 0.004
	label.modulate = Color(0.86,0.78,0.59)
	add_child(label)
	# The operational table and occupied console rows each sit beneath real
	# ceiling fixtures; bounded task pools preserve the dark containment shell.
	for light_x: float in [-12.0,0.0,12.0]:
		_box("OperationsCeilingLight",Vector3(x+light_x,y+4.34,z),Vector3(3.4,0.08,0.55),Color(0.73,0.84,0.80))
		var task_light := OmniLight3D.new()
		task_light.name = "OperationsTaskLight"
		task_light.position = Vector3(x+light_x,y+3.75,z)
		task_light.light_color = Color(0.78,0.91,0.87)
		task_light.light_energy = 4.5 if is_zero_approx(light_x) else 3.5
		task_light.omni_range = 20.0 if is_zero_approx(light_x) else 18.0
		task_light.shadow_enabled = false
		task_light.add_to_group("quality_practicals")
		add_child(task_light)
	_add_facility_zone(Rect2(-17.0,-77.0,34.0,21.0),y-0.2,y+1.0,"facility_ops")

func _build_sublevel_connectors() -> void:
	# Two broad switchback ramps provide walkable access to all three buried
	# levels; the framed shafts beside them are visual lift infrastructure.
	for floor_index: int in range(2):
		var upper_y: float = FLOORS_UNDER[floor_index]
		var lower_y: float = FLOORS_UNDER[floor_index+1]
		var center_y: float = (upper_y+lower_y)*0.5
		var angle := atan(absf(upper_y-lower_y)/8.0)
		var forward := floor_index % 2 == 0
		var center_z := -55.0
		var stair := _box("SublevelSwitchbackRamp_%d" % (floor_index+1),Vector3(0,center_y,center_z),Vector3(3.0,0.28,8.0),Color(0.35,0.40,0.41),true)
		stair.rotation.x = -angle if forward else angle
		for side: float in [-1.0,1.0]:
			var rail := _box("SublevelRampRail",Vector3(side*1.62,center_y+0.72,center_z),Vector3(0.12,1.45,8.0),Color(0.19,0.27,0.29),true)
			rail.rotation.x = stair.rotation.x
		for floor_y: float in [upper_y,lower_y]:
			_box("LiftShaftFrame",Vector3(5.8,floor_y+2.35,-55),Vector3(3.1,0.15,3.1),Color(0.37,0.46,0.45),true)
			_box("LiftCallPanel",Vector3(7.2,floor_y+1.2,-55),Vector3(0.10,1.5,0.42),Color(0.12,0.24,0.27))
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(5.8,center_y,-55)
		lamp.light_color = Color(0.29,0.75,0.82)
		lamp.light_energy = 0.6
		lamp.omni_range = 7.5
		lamp.shadow_enabled = false
		add_child(lamp)
func _build_buddha_interior() -> void:
	var first_interior_child := get_child_count()
	# A continuous hidden switchback corridor climbs from Sublevel 01 through
	# the plinth into the statue's first inner chamber. Its 21.6 m ramp rises
	# five metres (a gentle 13.4 degree slope); collision-backed sidewalls and a
	# ceiling keep the route concealed beneath the public stone shell.
	var core_length := sqrt(21.0*21.0+5.0*5.0)
	var core_angle := atan(5.0/21.0)
	var core_center := Vector3(0.0,-0.7,-39.5)
	var core_ramp := _box("StatueCoreConnectingRamp",core_center,Vector3(2.9,0.24,core_length),Color(0.38,0.39,0.35),true)
	core_ramp.rotation.x = -core_angle
	for side: float in [-1.0,1.0]:
		var corridor_wall := _box("StatueCoreCorridorWall",core_center+Vector3(side*1.58,1.55,0),Vector3(0.18,3.1,core_length),Color(0.29,0.31,0.29),true)
		corridor_wall.rotation.x = -core_angle
	var corridor_roof := _box("StatueCoreCorridorCeiling",core_center+Vector3(0,3.35,0),Vector3(3.55,0.20,core_length),Color(0.30,0.31,0.29),true)
	corridor_roof.rotation.x = -core_angle
	# Physical ramps climb through five chamber floors inside the statue shell.
	for i: int in range(FLOORS_INSIDE.size()-1):
		var low_y: float = FLOORS_INSIDE[i]
		var high_y: float = FLOORS_INSIDE[i+1]
		var center_y: float = (low_y+high_y)*0.5
		var center_x := 2.0
		var center_z := -29.0
		var stair := _box("BuddhaInteriorSwitchback_%d" % (i+1),Vector3(center_x,center_y,center_z),Vector3(2.0,0.24,8.0),Color(0.46,0.39,0.29),true)
		stair.rotation.x = -atan((high_y-low_y)/8.0) if i % 2 == 0 else atan((high_y-low_y)/8.0)
		for side: float in [-1.0,1.0]:
			var rail := _box("InteriorStairRail",Vector3(center_x+side*1.08,center_y+0.55,center_z),Vector3(0.10,1.1,8.0),Color(0.25,0.32,0.31),true)
			rail.rotation.x = stair.rotation.x
	for i: int in range(FLOORS_INSIDE.size()):
		var floor_y: float = FLOORS_INSIDE[i]
		var width: float = [16.0,16.0,14.0,12.0,8.0][i]
		var depth: float = [14.0,14.0,12.0,10.5,7.5][i]
		var tint := Color(0.44,0.36,0.26).lerp(Color(0.20,0.36,0.41),float(i)/4.0)
		if i == 0:
			# Keep a 3.2 m by 10 m shaft open above the rising core ramp;
			# adjacent slabs leave the public interior floor continuous.
			var side_width: float = (width-3.2)*0.5
			for side: float in [-1.0,1.0]:
				_box("ConcealedBuddhaInteriorFloor_1_Side",Vector3(side*(1.6+side_width*0.5),floor_y-0.18,-29),Vector3(side_width,0.36,depth),tint,true)
			_box("ConcealedBuddhaInteriorFloor_1_Front",Vector3(0,floor_y-0.18,-24.5),Vector3(3.2,0.36,5.0),tint,true)
		else:
			_box("ConcealedBuddhaInteriorFloor_%d" % (i+1),Vector3(0,floor_y-0.18,-29),Vector3(width,0.36,depth),tint,true)
		for side: float in [-1.0,1.0]:
			_box("BuddhaInteriorWall",Vector3(side*width*0.5,floor_y+1.78,-29),Vector3(0.22,3.55,depth),tint.darkened(0.25),true)
		for front_back: float in [-1.0,1.0]:
			var wall_z: float = -29+front_back*depth*0.5
			if i == 0 and front_back < 0.0:
				var wall_side_width: float = (width-3.4)*0.5
				for side: float in [-1.0,1.0]:
					_box("BuddhaInteriorEntryWall",Vector3(side*(1.7+wall_side_width*0.5),floor_y+1.78,wall_z),Vector3(wall_side_width,3.55,0.22),tint.darkened(0.25),true)
			else:
				_box("BuddhaInteriorWall",Vector3(0,floor_y+1.78,wall_z),Vector3(width,3.55,0.22),tint.darkened(0.25),true)
		for rib_x: float in [-width*0.35,width*0.35]:
			_box("BronzeInnerRib",Vector3(rib_x,floor_y+1.55,-29),Vector3(0.18,3.1,depth-0.6),Color(0.63,0.49,0.30),true)
		var title: String = ["PEDESTAL  /  INNER ACCESS", "ROBE SHELL  /  SERVICE GALLERY", "HIDDEN RIB CORRIDOR", "UPPER ROBE  /  ARCHIVE", "CROWN CHAMBER  /  INNER VAULT"][i]
		var sign := Label3D.new()
		sign.text = title
		sign.position = Vector3(0,floor_y+3.05,-29-depth*0.5+0.16)
		sign.font_size = 18
		sign.pixel_size = 0.004
		sign.modulate = Color(0.86,0.75,0.54)
		add_child(sign)
		_add_navigation("BuddhaInteriorNavigation_%d" % (i+1),floor_y+0.04,-29-depth*0.5+0.7,-29+depth*0.5-0.7,-width*0.5+0.8,width*0.5-0.8)
		_add_facility_zone(Rect2(-width*0.5,-29-depth*0.5,width,depth),floor_y-0.2,floor_y+0.9,"buddha_interior")
		var console_width: float = minf(width*0.28,3.0)
		var console_x: float = width*0.5-console_width*0.5-0.5
		_box("ConcealedCentralArchiveConsole",Vector3(console_x,floor_y+0.58,-29),Vector3(console_width,1.1,1.0),Color(0.17,0.25,0.28),true)
		_box("InnerArchiveConsoleLight",Vector3(console_x,floor_y+1.17,-29.25),Vector3(console_width*0.8,0.05,0.06),Color(0.24,0.70,0.72))
		var chamber_light := OmniLight3D.new()
		chamber_light.name = "BuddhaInteriorPractical_%d" % (i+1)
		chamber_light.position = Vector3(0,floor_y+3.12,-29)
		chamber_light.light_color = Color(1.0,0.76,0.48) if i == 0 else Color(0.72,0.86,0.84)
		chamber_light.light_energy = 0.78
		chamber_light.omni_range = 9.0
		chamber_light.shadow_enabled = false
		chamber_light.add_to_group("quality_practicals")
		var service := get_node_or_null("/root/Campaign")
		if service:
			var settings: Dictionary = service.get("settings")
			chamber_light.visible = str(settings.get("graphics","MEDIUM")) != "LOW" and bool(settings.get("practicals",true))
		add_child(chamber_light)
	# This hidden passage opens into the upper operations galleries and shows the
	# statue's internal structural ribs as part of the facility architecture.
	_add_facility_zone(Rect2(-8.0,-36.0,16.0,14.0),1.6,21.0,"buddha_interior")
	# Keep every world-space chamber piece (including the inner nav regions) out
	# of the public view. A single group of toggled nodes follows the real player
	# entry state, rather than a hidden-shell camera trick or moving geometry.
	for child_index: int in range(first_interior_child,get_child_count()):
		var interior_node := get_child(child_index) as Node3D
		if interior_node:
			interior_node.visible = false
			statue_interior_nodes.append(interior_node)

func _add_navigation(region_name: String, y: float, z_min: float, z_max: float, x_min: float, x_max: float) -> void:
	var region := NavigationRegion3D.new()
	region.name = region_name
	region.position = Vector3(0,y,0)
	var navigation := NavigationMesh.new()
	navigation.vertices = PackedVector3Array([Vector3(x_min,0,z_min),Vector3(x_max,0,z_min),Vector3(x_max,0,z_max),Vector3(x_min,0,z_max)])
	navigation.add_polygon(PackedInt32Array([0,3,2,1]))
	region.navigation_mesh = navigation
	add_child(region)

func _add_facility_zone(rect: Rect2, floor_min: float, floor_max: float, area: String) -> void:
	if not world: return
	var zones: Variant = world.get("access_zones")
	if not zones is Array: return
	zones.push_front({"rect":rect,"floor_min":floor_min,"floor_max":floor_max,"area":area})
	world.set("access_zones",zones)

func _build_access_zones() -> void:
	_add_facility_zone(Rect2(-28,-80,56,46),-4.0,1.0,"facility_staff")
	_add_facility_zone(Rect2(-10,-53,20,7),-4.0,0.2,"facility_checkpoint")
	_add_facility_zone(Rect2(-28,-77,18,16),-4.0,-2.0,"facility_maintenance")
	_add_facility_zone(Rect2(-28,-80,56,46),-9.0,-7.0,"facility_research")
	_add_facility_zone(Rect2(-17,-77,34,21),-9.0,-7.0,"facility_ops")
	_add_facility_zone(Rect2(-28,-80,56,46),-14.0,-12.0,"facility_ops")
	_add_facility_zone(Rect2(-28,-54,56,18),-14.0,-12.0,"facility_maintenance")

func _build_level_lighting(floor_y: float, center_z: float, tint: Color) -> void:
	# Four cross-aisle rows keep the central circulation and occupied rooms lit;
	# twelve-metre lateral spacing closes the previous sixteen-metre centre gap.
	for x: float in [-18.0,-6.0,6.0,18.0]:
		for z: float in [center_z-17.0,center_z,center_z+17.0]:
			_box("RecessedFacilityLuminaire",Vector3(x,floor_y+4.62,z),Vector3(2.2,0.08,0.32),tint.lightened(0.48))
			var lamp := OmniLight3D.new()
			lamp.name = "FacilityCeilingPractical_%03d_%02d_%02d" % [int(absf(floor_y)*10.0),int(x+25.0),int(z-center_z+18.0)]
			lamp.position = Vector3(x,floor_y+3.85,z)
			lamp.light_color = Color(0.68,0.80,0.82) if floor_y > -10.0 else Color(0.98,0.72,0.48)
			lamp.light_energy = 3.2
			lamp.omni_range = 17.0
			lamp.shadow_enabled = false
			lamp.add_to_group("quality_practicals")
			var graphics_quality := "MEDIUM"
			var practicals_enabled := true
			var campaign_service := get_node_or_null("/root/Campaign")
			if campaign_service:
				var quality_settings: Dictionary = campaign_service.get("settings")
				graphics_quality = str(quality_settings.get("graphics","MEDIUM"))
				practicals_enabled = bool(quality_settings.get("practicals",true))
			var central_fallback := is_equal_approx(absf(x),6.0) and is_equal_approx(z,center_z)
			lamp.visible = practicals_enabled and (graphics_quality != "LOW" or central_fallback)
			add_child(lamp)

func _build_staff_routes() -> void:
	if not world: return
	_add_staff("Monument access security","security",Vector3(-5,-3.15,-47),Vector3(5,-3.15,-47),"facility_security")
	_add_staff("Facility records clerk","facility_research",Vector3(-15,-3.15,-48),Vector3(-20,-3.15,-48),"facility_research")
	_add_staff("Sublevel one maintenance","facility_technician",Vector3(-18,-3.15,-68),Vector3(-12,-3.15,-68),"facility_technician")
	_add_staff("Facility residential attendant","facility_research",Vector3(14,-3.15,-69),Vector3(21,-3.15,-69),"facility_research")
	_add_staff("Research lab specialist","facility_research",Vector3(-18,-8.15,-49),Vector3(-11,-8.15,-49),"facility_research")
	_add_staff("Surveillance operator","facility_research",Vector3(18,-8.15,-49),Vector3(12,-8.15,-49),"facility_research")
	_add_staff("Operations director","facility_director",Vector3(0,-8.15,-66),Vector3(6,-8.15,-65),"facility_director")
	_add_staff("Directorate aide","employee",Vector3(18,-8.15,-70),Vector3(12,-8.15,-70),"facility_research")
	_add_staff("Transit systems engineer","facility_technician",Vector3(0,-13.15,-47),Vector3(7,-13.15,-47),"facility_technician")
	_add_staff("Vault security officer","security",Vector3(-15,-13.15,-67),Vector3(-22,-13.15,-67),"facility_security")
	_add_staff("Plant room specialist","facility_technician",Vector3(18,-13.15,-67),Vector3(12,-13.15,-67),"facility_technician")
	_add_staff("Inner-structure archivist","facility_research",Vector3(-3,1.85,-29),Vector3(3,1.85,-29),"facility_research")
	_add_staff("Crown chamber attendant","facility_director",Vector3(0,17.85,-29),Vector3(1,17.85,-28),"facility_director")

func _add_staff(identity: String, occupation: String, start: Vector3, finish: Vector3, outfit: String) -> void:
	var npc_variant: Variant = world.call("_target",identity,occupation,start,finish)
	if not npc_variant is HotelNpc: return
	var npc := npc_variant as HotelNpc
	npc.profile.outfit_id = outfit
	npc.person.set_outfit(outfit)
	npc.profile.alertness = 0.42
	npc.profile.curiosity = 0.38
	npc.profile.schedule.clear()
	npc.profile.schedule.append(ScheduleEntry.new(finish,"working",4.0))
	npc.profile.schedule.append(ScheduleEntry.new(start,"conversing",3.5))

func _build_room_partition_wall(name: String, center: Vector3, size: Vector3, color: Color) -> void:
	_box(name,center,size,color,true)

func _box(node_name: String, center: Vector3, size: Vector3, tint: Color, solid: bool = false) -> Node3D:
	var holder: Node3D = StaticBody3D.new() if solid else Node3D.new()
	holder.name = node_name
	holder.position = center
	add_child(holder)
	var mesh_instance := MeshInstance3D.new()
	var key := str(size)
	if not mesh_cache.has(key):
		var mesh := BoxMesh.new()
		mesh.size = size
		mesh_cache[key] = mesh
	mesh_instance.mesh = mesh_cache[key]
	var finish := "concrete"
	if node_name.contains("Rail") or node_name.contains("Frame") or node_name.contains("Rib") or node_name.contains("Panel") or node_name.contains("Rack") or node_name.contains("Pipe") or node_name.contains("Conduit") or node_name.contains("Door") or node_name.contains("Vent") or node_name.contains("Skirting"):
		finish = "brushed_metal"
	elif node_name.contains("Light") or node_name.contains("Lamp") or node_name.contains("Luminaire") or node_name.contains("Guide") or node_name.contains("Display") or node_name.contains("Screen") or node_name.contains("Status"):
		finish = "emissive"
	elif node_name.contains("Floor") or node_name.contains("Ramp") or node_name.contains("Slab") or node_name.contains("Threshold"):
		finish = "terrazzo"
	elif node_name.contains("Desk") or node_name.contains("Worktop") or node_name.contains("Table") or node_name.contains("Drawer"):
		finish = "wood"
	elif node_name.contains("Chair") or node_name.contains("Mattress") or node_name.contains("Cover") or node_name.contains("Pillow"):
		finish = "fabric"
	var material_key := tint.to_html(true) + ":" + finish
	if not material_cache.has(material_key):
		material_cache[material_key] = StationMaterials.material(tint,finish)
	mesh_instance.material_override = material_cache[material_key]
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if not solid else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	holder.add_child(mesh_instance)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		holder.add_child(collision)
	return holder

func _material(tint: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = roughness
	return material
