class_name ConstructionKit
extends RefCounted
## Reusable, collision-neutral architectural assemblies. These are construction
## details (reveals, frames, service runs), not decorative prop scatter.
static var box_meshes: Dictionary = {}
static var box_materials: Dictionary = {}

static func box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	color: Color,
	roughness: float = 0.82,
	emission_energy: float = 0.0
) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = name
	if not box_meshes.has(size):
		var mesh := BoxMesh.new()
		mesh.size = size
		box_meshes[size] = mesh
	visual.mesh = box_meshes[size]
	var key := color.to_html(true) + ":" + str(roughness) + ":" + str(emission_energy)
	if not box_materials.has(key):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = roughness
		if color.a < 0.999:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
		if emission_energy > 0.0:
			material.emission_enabled = true
			material.emission = color
			material.emission_energy_multiplier = emission_energy
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		box_materials[key] = material
	visual.material_override = box_materials[key]
	visual.position = position
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(visual)
	return visual

static func door_portal(
	parent: Node3D,
	label: String,
	center: Vector3,
	width: float,
	height: float,
	depth: float,
	trim: Color,
	threshold: Color = Color(0.54, 0.48, 0.36)
) -> void:
	var jamb_width := minf(0.16, width * 0.055)
	box(parent, label + "LeftReveal", center + Vector3(-width * 0.5 + jamb_width * 0.5, height * 0.5, 0.0), Vector3(jamb_width, height, depth), trim)
	box(parent, label + "RightReveal", center + Vector3(width * 0.5 - jamb_width * 0.5, height * 0.5, 0.0), Vector3(jamb_width, height, depth), trim)
	box(parent, label + "Head", center + Vector3(0.0, height - jamb_width * 0.5, 0.0), Vector3(width, jamb_width, depth), trim)
	box(parent, label + "Threshold", center + Vector3(0.0, 0.035, depth * 0.55), Vector3(width - 0.12, 0.07, depth * 2.0), threshold, 0.62)

static func glazed_bay(
	parent: Node3D,
	label: String,
	center: Vector3,
	width: float,
	height: float,
	depth: float,
	frame: Color,
	glass: Color,
	vertical_mullions: int = 1
) -> void:
	var rail := 0.09
	box(parent, label + "Glass", center, Vector3(width - rail * 1.4, height - rail * 1.6, maxf(0.025, depth * 0.35)), glass, 0.22)
	for side: float in [-1.0, 1.0]:
		box(parent, label + "Jamb", center + Vector3(side * (width - rail) * 0.5, 0.0, depth * 0.35), Vector3(rail, height, depth), frame, 0.5)
	box(parent, label + "Head", center + Vector3(0.0, (height - rail) * 0.5, depth * 0.35), Vector3(width, rail, depth), frame, 0.5)
	box(parent, label + "Sill", center + Vector3(0.0, -(height - rail) * 0.5, depth * 0.55), Vector3(width + 0.18, rail, depth * 1.8), frame, 0.52)
	for index: int in range(1, vertical_mullions + 1):
		var mullion_x := -width * 0.5 + width * float(index) / float(vertical_mullions + 1)
		box(parent, label + "Mullion", center + Vector3(mullion_x, 0.0, depth * 0.46), Vector3(0.045, height - rail, depth * 0.72), frame, 0.48)

static func service_riser(
	parent: Node3D,
	label: String,
	base: Vector3,
	height: float,
	pipe_color: Color,
	cover_color: Color,
	pipe_count: int = 3
) -> void:
	var shaft_width := 0.54
	box(parent, label + "Recess", base + Vector3(0.0, height * 0.5, 0.0), Vector3(shaft_width, height, 0.12), cover_color.darkened(0.3), 0.9)
	for index: int in range(pipe_count):
		var x := -0.17 + float(index) * 0.17
		var pipe := MeshInstance3D.new()
		pipe.name = label + "Pipe_%d" % index
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.035 if index == 0 else 0.024
		cylinder.bottom_radius = cylinder.top_radius
		cylinder.height = height - 0.24
		cylinder.radial_segments = 8
		pipe.mesh = cylinder
		var material := StandardMaterial3D.new()
		material.albedo_color = pipe_color if index == 0 else pipe_color.darkened(0.24)
		material.roughness = 0.48
		pipe.material_override = material
		pipe.position = base + Vector3(x, height * 0.5, 0.10)
		pipe.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(pipe)
	for y_fraction: float in [0.18, 0.50, 0.82]:
		box(parent, label + "PipeClamp", base + Vector3(0.0, height * y_fraction, 0.16), Vector3(0.62, 0.055, 0.06), cover_color.lightened(0.16), 0.48)
	box(parent, label + "AccessPanel", base + Vector3(0.0, 0.72, 0.21), Vector3(0.40, 0.58, 0.055), cover_color.lightened(0.08), 0.76)
	box(parent, label + "PanelHandle", base + Vector3(0.12, 0.72, 0.25), Vector3(0.035, 0.13, 0.025), pipe_color, 0.45)

static func trim_run(
	parent: Node3D,
	label: String,
	start: Vector3,
	end: Vector3,
	thickness: float,
	color: Color
) -> void:
	var delta := end - start
	var midpoint := (start + end) * 0.5
	var visual := box(parent, label, midpoint, Vector3(delta.length(), thickness, thickness), color, 0.66)
	visual.rotation.y = atan2(delta.z, delta.x)
