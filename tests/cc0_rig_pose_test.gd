extends SceneTree
## Runtime pose and full-resolution lineup regression for every bundled CC0 model.
## These views prove the current imported scenes render at each pose; they still
## require visual review and are not a substitute for an interactive playtest.

const MODEL_NAMES: Array[String] = [
	"brad", "dale", "ellie", "gary", "hollis", "pickles", "rosa", "vance"
]
const OUTFITS: Array[String] = [
	"market_vendor",
	"hospitality",
	"office_employee",
	"facility_security",
	"executive",
	"facility_research",
	"hotel_staff",
	"maintenance"
]
const OUTFIT_MODELS: Array[String] = [
	"dale", "rosa", "brad", "gary", "pickles", "ellie", "vance", "dale"
]
var checks := 0
var failures := 0
var world: Node3D
var camera: Camera3D
var people: Array[StylizedPerson] = []
var output_dir := ""


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("CC0 RIG PASS: ", label)
	else:
		failures += 1
		printerr("CC0 RIG FAIL: ", label)
		var safe_label := label.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
		print("::error title=CC0 rig assertion::", safe_label)


func _pose_vector(skeleton: Skeleton3D, from_name: String, to_name: String) -> Vector3:
	var from_index := skeleton.find_bone(from_name)
	var to_index := skeleton.find_bone(to_name)
	if from_index < 0 or to_index < 0:
		return Vector3.ZERO
	return (
		skeleton.get_bone_global_pose(to_index).origin
		- skeleton.get_bone_global_pose(from_index).origin
	)


func _stage() -> void:
	root.size = Vector2i(1280, 720)
	world = Node3D.new()
	world.name = "Cc0RigRegressionStage"
	root.add_child(world)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.10, 0.14, 0.18)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.74, 0.79, 0.84)
	env.ambient_light_energy = 0.75
	environment.environment = env
	world.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_energy = 1.35
	world.add_child(sun)
	var floor := MeshInstance3D.new()
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(18.0, 0.12, 5.0)
	floor.mesh = floor_mesh
	floor.position = Vector3(0.0, -0.06, 0.0)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.29, 0.33, 0.34)
	floor_material.roughness = 0.92
	floor.material_override = floor_material
	world.add_child(floor)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 9.1
	camera.position = Vector3(0.0, 5.0, 15.0)
	world.add_child(camera)
	camera.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)
	camera.make_current()
	for index: int in range(MODEL_NAMES.size()):
		var person := StylizedPerson.new()
		person.role = "civilian"
		person.appearance_seed = index
		person.name = "CC0_" + MODEL_NAMES[index]
		person.position = Vector3((float(index) - 3.5) * 1.55, 0.0, 0.0)
		person.rotation.y = PI
		world.add_child(person)
		people.append(person)
		var label := Label3D.new()
		label.text = MODEL_NAMES[index].to_upper()
		label.font_size = 44
		label.pixel_size = 0.006
		label.position = Vector3(0.0, 2.16, 0.0)
		label.rotation.y = PI
		label.modulate = Color(0.94, 0.84, 0.65)
		person.add_child(label)


func _settle_all(delta: float, speed: float, frame_count: int) -> void:
	for frame: int in range(frame_count):
		for person: StylizedPerson in people:
			person.animate_motion(delta, speed)
		await process_frame
	for person: StylizedPerson in people:
		if person.cc0_skeleton:
			person.cc0_skeleton.force_update_all_bone_transforms()


func _capture(name: String) -> void:
	for frame: int in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var valid := image != null and image.get_width() == 1280 and image.get_height() == 720
	check(valid, name + " renders at native 1280x720")
	if not valid:
		return
	var path := output_dir.path_join(name + ".png")
	check(image.save_png(path) == OK, name + " saved as lossless PNG")
	var preview := image.duplicate() as Image
	preview.resize(320, 180, Image.INTERPOLATE_LANCZOS)
	var preview_path := output_dir.path_join(name + "_preview.jpg")
	check(preview.save_jpg(preview_path, 0.72) == OK, name + " produced a review thumbnail")
	print("CC0 RIG CAPTURE: ", path, " [1280x720]")


func _check_each_model() -> void:
	for index: int in range(people.size()):
		var person := people[index]
		var expected := MODEL_NAMES[index]
		check(
			person.cc0_model != null and person.cc0_model_name == expected,
			expected + " selected its own imported CC0 scene"
		)
		check(person.cc0_skeleton != null, expected + " has an imported Skeleton3D")
		if person.cc0_skeleton == null:
			continue
		var left_leg := _pose_vector(person.cc0_skeleton, "upperleg01.L", "foot.L")
		var right_leg := _pose_vector(person.cc0_skeleton, "upperleg01.R", "foot.R")
		var standing := left_leg.length() > 0.2 and right_leg.length() > 0.2
		standing = standing and left_leg.normalized().dot(Vector3.DOWN) > 0.80
		standing = standing and right_leg.normalized().dot(Vector3.DOWN) > 0.80
		check(standing, expected + " stands upright on both legs")
		var left_arm := _pose_vector(person.cc0_skeleton, "upperarm01.L", "wrist.L")
		var right_arm := _pose_vector(person.cc0_skeleton, "upperarm01.R", "wrist.R")
		var arms_down := left_arm.length() > 0.12 and right_arm.length() > 0.12
		arms_down = arms_down and left_arm.y < -0.10 and right_arm.y < -0.10
		check(arms_down, expected + " keeps both arms below the shoulder line")


func run() -> void:
	output_dir = OS.get_environment("CC0_RIG_SCREENSHOT_DIR")
	if output_dir.is_empty():
		output_dir = OS.get_environment("TEST_SCREENSHOT_DIR")
	if output_dir.is_empty():
		output_dir = "user://cc0_rig_regression"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	_stage()
	for frame: int in range(8):
		await process_frame
	await _settle_all(1.0 / 30.0, 0.0, 32)
	_check_each_model()
	await _capture("cc0_8_models_standing")
	await _settle_all(1.0 / 30.0, 1.45, 44)
	await _capture("cc0_8_models_walking")
	for person: StylizedPerson in people:
		person.crouch_amount = 1.0
	await _settle_all(1.0 / 30.0, 0.0, 32)
	for person: StylizedPerson in people:
		check(
			person.cc0_model.position.y <= -0.29,
			person.cc0_model_name + " lowers the imported body during crouch"
		)
	await _capture("cc0_8_models_crouching")
	for person: StylizedPerson in people:
		person.crouch_amount = 0.0
		person.set_seated(true)
	await _settle_all(1.0 / 30.0, 0.0, 32)
	for person: StylizedPerson in people:
		check(
			absf(person.cc0_model.position.y + 0.42) < 0.02,
			person.cc0_model_name + " applies the imported seated-body offset"
		)
	await _capture("cc0_8_models_seated")
	for index: int in range(people.size()):
		people[index].set_seated(false)
		people[index].set_outfit(OUTFITS[index])
	await _settle_all(1.0 / 30.0, 0.0, 40)
	for index: int in range(people.size()):
		var person := people[index]
		check(
			person.cc0_model != null and person.cc0_model_name == OUTFIT_MODELS[index],
			OUTFITS[index] + " resolves to its intended skinned disguise model"
		)
		check(
			person.cc0_skeleton != null and not person.cc0_clothes.is_empty(),
			OUTFITS[index] + " retains its articulated body and clothing meshes"
		)
	await _capture("cc0_8_models_disguise_outfits")
	# A separate close framing lets reviewers inspect face, shoulders, sleeves,
	# hands, waist and knees without using a pose to conceal the body silhouette.
	camera.size = 3.6
	camera.position = Vector3(2.32, 3.35, 8.0)
	camera.look_at(Vector3(2.32, 1.15, 0.0), Vector3.UP)
	await _capture("cc0_anatomy_clothing_closeup")
	print(
		"CC0 RIG RESULT: ",
		checks,
		" checks, ",
		failures,
		" failures; 6 current-build rig views staged"
	)
	quit(0 if failures == 0 else 1)
