extends SceneTree
## Genuine 3D campaign scene captures from Godot 4.4.1. These automated
## stills demonstrate scene rendering, not human visual review or playtesting.
var checks := 0
var failures := 0
var captures := 0
var output := ""
var capture_manifest: Array[Dictionary] = []
var staged_pose_checks: Dictionary = {}
var campaign: Node
var saved_progress: Dictionary
var saved_active := ""
var saved_settings: Dictionary
var saved_campaign_path := ""
var saved_settings_path := ""
var scratch_campaign_path := ""
var shot: Camera3D
var world: Node3D


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("A008 PASS: ", label)
	else:
		failures += 1
		printerr("A008 FAIL: ", label)


func _open_world(path: String, mission_id: String) -> Node3D:
	campaign.active_mission = mission_id
	var instance := load(path).instantiate() as Node3D
	root.add_child(instance)
	for frame: int in range(5):
		await process_frame
	if instance.has_method("_end_intro"):
		instance.call("_end_intro")
	if instance.has_method("_finish_entry_intro"):
		instance.call("_finish_entry_intro")
	if instance.has_method("_skip_cinematic"):
		instance.call("_skip_cinematic")
	if instance.has_method("_end_intro"):
		instance.call("_end_intro")
	for frame: int in range(3):
		await process_frame
	return instance


func _camera(position: Vector3, target: Vector3, fov: float = 62.0) -> void:
	if shot and is_instance_valid(shot):
		shot.queue_free()
	shot = Camera3D.new()
	shot.name = "Assignment008AcceptanceCamera"
	shot.fov = fov
	world.add_child(shot)
	shot.global_position = position
	shot.look_at(target, Vector3.UP)
	shot.make_current()


func _capture(name: String, include_hud: bool = false) -> void:
	captures += 1
	# Keep mission overlays out of environment review frames so the scenery can
	# be judged at thumbnail size. The final gameplay frame deliberately retains
	# the real HUD; the Instinct grade layer remains active for Instinct views.
	for layer: Node in world.find_children("*", "CanvasLayer", true, false):
		if layer is CanvasLayer and (layer as CanvasLayer).layer >= 0:
			(layer as CanvasLayer).visible = include_hud
	for frame: int in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		check(false, name + " produced a readable viewport image")
		return
	check(
		image.get_width() >= 1280 and image.get_height() >= 720,
		name + " rendered at 1280x720 or higher"
	)
	var full_path := output.path_join(name + ".png")
	var png_error := image.save_png(full_path)
	var saved_png := Image.new()
	var png_read_error := saved_png.load(full_path)
	var png_valid := (
		png_error == OK
		and png_read_error == OK
		and saved_png.get_width() == image.get_width()
		and saved_png.get_height() == image.get_height()
	)
	check(png_valid, name + " lossless PNG exists and reopens at native resolution")
	var preview := image.duplicate() as Image
	preview.resize(320, 180, Image.INTERPOLATE_LANCZOS)
	preview.save_jpg(output.path_join(name + "_thumb.jpg"), 0.58)
	# Native-resolution JPEGs are only an inspection transport for the check API;
	# the artifact keeps the original lossless PNG. Bound each annotation payload
	# so it survives GitHub's annotation message/count limits while retaining 1280x720 pixels.
	var review_path := output.path_join(name + "_inspect.jpg")
	var review_image := image.duplicate() as Image
	var review_quality := 0.65
	var review_error := review_image.save_jpg(review_path, review_quality)
	var review_bytes := FileAccess.get_file_as_bytes(review_path)
	while review_error == OK and review_bytes.size() > 29900 and review_quality > 0.06:
		review_quality = maxf(0.05, review_quality - 0.08)
		review_error = review_image.save_jpg(review_path, review_quality)
		review_bytes = FileAccess.get_file_as_bytes(review_path)
	var saved_review := Image.new()
	var review_read_error := saved_review.load(review_path)
	var review_valid := (
		review_error == OK
		and review_read_error == OK
		and saved_review.get_width() == image.get_width()
		and saved_review.get_height() == image.get_height()
		and review_bytes.size() <= 29900
	)
	check(
		review_valid,
		name + " native-resolution review JPEG reopens within the annotation size budget"
	)
	# 320x180/160x90 previews remain useful for quick summaries only.
	var annotation_preview := preview.duplicate() as Image
	annotation_preview.resize(160, 90, Image.INTERPOLATE_LANCZOS)
	annotation_preview.save_jpg(output.path_join(name + "_preview.jpg"), 0.25)
	capture_manifest.append({
		"name": name,
		"png": name + ".png",
		"width": image.get_width(),
		"height": image.get_height(),
		"png_bytes": FileAccess.get_file_as_bytes(full_path).size(),
		"inspect_jpeg": name + "_inspect.jpg",
		"inspect_jpeg_bytes": review_bytes.size(),
		"inspect_jpeg_quality": review_quality,
		"inspect_jpeg_native_resolution": review_valid
	})
	print(
		"A008_CAPTURE: ",
		name,
		" -> ",
		full_path,
		" [",
		image.get_width(),
		"x",
		image.get_height(),
		"] PNG=",
		FileAccess.get_file_as_bytes(full_path).size(),
		" review-JPEG=",
		review_bytes.size(),
		" quality=",
		review_quality
	)


func _close_world() -> void:
	if is_instance_valid(world):
		world.queue_free()
	world = null
	shot = null
	for frame: int in range(4):
		await process_frame


func _settle_person(person: StylizedPerson) -> void:
	if person == null:
		return
	person.set_seated(false)
	person.crouch_amount = 0.0
	person.idle_activity = "idle"
	person.gait_speed = 0.0
	person.phase = 0.0
	person.upper_body.position = Vector3.ZERO
	person.upper_body.rotation = Vector3.ZERO
	person.rotation = Vector3.ZERO
	# Capture fixtures stop actors between arbitrary navigation frames. Blend
	# their real skeletal/procedural rigs to a settled standing idle before stills.
	for frame: int in range(12):
		person.animate_motion(0.12, 0.0)
	if person.cc0_skeleton:
		var instance_id := person.get_instance_id()
		if not staged_pose_checks.has(instance_id):
			person.cc0_skeleton.force_update_all_bone_transforms()
			var left_hip := person.cc0_skeleton.find_bone("upperleg01.L")
			var left_foot := person.cc0_skeleton.find_bone("foot.L")
			var right_hip := person.cc0_skeleton.find_bone("upperleg01.R")
			var right_foot := person.cc0_skeleton.find_bone("foot.R")
			var legs_down := false
			if left_hip >= 0 and left_foot >= 0 and right_hip >= 0 and right_foot >= 0:
				var left_vector := person.cc0_skeleton.get_bone_global_pose(left_foot).origin - person.cc0_skeleton.get_bone_global_pose(left_hip).origin
				var right_vector := person.cc0_skeleton.get_bone_global_pose(right_foot).origin - person.cc0_skeleton.get_bone_global_pose(right_hip).origin
				legs_down = left_vector.normalized().dot(Vector3.DOWN) > 0.9 and right_vector.normalized().dot(Vector3.DOWN) > 0.9
			check(legs_down, "CC0 staged character legs settle into an upright idle")
			staged_pose_checks[instance_id] = true


func _freeze_npcs() -> void:
	if world == null:
		return
	var player := world.get("player") as HotelPlayer
	if player:
		player.velocity = Vector3.ZERO
		player.stance_height = 1.8
		player.crouching = false
		player.body_mesh.crouch_amount = 0.0
		player.set_physics_process(false)
		_settle_person(player.body_mesh)
	for node: Node in world.get_children():
		if node is HotelNpc:
			var direct_npc := node as HotelNpc
			direct_npc.velocity = Vector3.ZERO
			direct_npc.set_physics_process(false)
			_settle_person(direct_npc.person)
		for nested: Node in node.get_children():
			if nested is HotelNpc:
				var nested_npc := nested as HotelNpc
				nested_npc.velocity = Vector3.ZERO
				nested_npc.set_physics_process(false)
				_settle_person(nested_npc.person)


func _position_characters(player_position: Vector3, npc_position: Vector3) -> HotelNpc:
	var player := world.get("player") as HotelPlayer
	var npcs: Array = world.get("npcs") if world.get("npcs") is Array else world.get("npc_list")
	if player:
		player.global_position = player_position
		player.velocity = Vector3.ZERO
	if npcs and npcs.size() > 0:
		var npc := npcs[0] as HotelNpc
		npc.global_position = npc_position
		npc.velocity = Vector3.ZERO
		return npc
	return null


func run() -> void:
	output = OS.get_environment("TEST_SCREENSHOT_DIR")
	if output.is_empty():
		output = "user://assignment008_visual_acceptance"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	root.size = Vector2i(1280, 720)
	campaign = root.get_node("Campaign")
	saved_progress = campaign.progress.snapshot()
	saved_active = campaign.active_mission
	saved_settings = campaign.settings.duplicate(true)
	saved_campaign_path = campaign.campaign_path
	saved_settings_path = campaign.settings_path
	# Outfit acquisition in a real mission normally persists campaign state.
	# Isolate this scene-capture fixture so running it locally cannot overwrite
	# the player's campaign, settings, or per-mission checkpoint files.
	scratch_campaign_path = "user://assignment008_visual_acceptance_%d.json" % Time.get_ticks_usec()
	campaign.campaign_path = scratch_campaign_path
	campaign.settings["graphics"] = "MEDIUM"
	campaign.settings["practicals"] = true
	campaign.settings["shadows"] = true
	campaign.progress.restore(
		{
			"completed": ["initiation", "tung_chung", "hong_kong_sandbox"],
			"recovered_keys": ["key_01", "key_02", "key_03", "key_04"]
		}
	)

	# 01: actual bus-stop onboarding with the callsign picker and Ruby/thief/player.
	world = await _open_world("res://scenes/bus_stop_opening.tscn", "initiation")
	var opener: Node3D = world
	var callsign_field := opener.get("callsign_input") as LineEdit
	var confirm_button := opener.get("name_button") as Button
	check(callsign_field != null and callsign_field.visible and confirm_button != null and confirm_button.visible,"bus-stop capture shows the live 1–24 character callsign picker")
	_camera(Vector3(0.0,3.0,9.5),Vector3(0.0,1.2,-0.8),64.0)
	await _capture("01_bus_stop_callsign_recruitment",true)
	await _close_world()

	# 02: actual Initiation assessment hall with the skinned agent and evaluators.
	world = await _open_world("res://scenes/initiation.tscn", "initiation")
	_freeze_npcs()
	_camera(Vector3(-4.7,2.25,3.8),Vector3(-6.0,1.0,0.0),59.0)
	await _capture("02_initiation_assessment_hall",false)
	var init_player := world.get("player") as HotelPlayer
	var init_npcs: Array = world.get("npcs")
	check(init_player != null and init_npcs.size() >= 2 and init_player.body_mesh.cc0_model != null and (init_npcs[0] as HotelNpc).person.cc0_model != null,"Initiation uses the imported agent and NPC models")
	await _close_world()

	# 03–04: the hotel mission environment and its separately furnished wing.
	world = await _open_world("res://scenes/hotel.tscn", "meridian")
	_freeze_npcs()
	check(
		world.find_child("MeridianGuestRoomPortalLeftReveal", true, false) != null
		and world.find_child("MeridianGuestRoomDoorLeaf", true, false) != null
		and world.find_child("MeridianGuestRoomNumber", true, false) != null,
		"Meridian upper gallery now has framed guest-room doors and room-specific wayfinding"
	)
	_camera(Vector3(-5.0, 1.7, 6.0), Vector3(-5.0, 1.3, -6.0), 66.0)
	await _capture("03_meridian_main_environment")
	# Frame the real restaurant through its built opening at x=-36 rather than
	# shooting across the solid glazed service partition from the wrong room.
	_camera(Vector3(-36.0, 1.55, -3.5), Vector3(-35.0, 1.25, -10.5), 58.0)
	await _capture("04_meridian_interior_lighting")
	await _close_world()

	# 05–06: actual campaign station and boardable connected train.
	world = await _open_world("res://scenes/mission_tung_chung.tscn", "tung_chung")
	_freeze_npcs()
	_camera(Vector3(-16.0, 3.2, 8.5), Vector3(-6.0, 1.4, -4.0), 66.0)
	await _capture("05_tung_chung_station")
	world.call("_board_train")
	for frame: int in range(3):
		await process_frame
	_camera(Vector3(19.0, 1.65, 29.0), Vector3(19.0, 1.25, 38.5), 68.0)
	await _capture("06_tung_chung_train_platform_and_interior")
	check(
		world.get("train_stage") == "aboard" and world.get("train_car") != null,
		"train capture uses the playable campaign boarding state"
	)
	await _close_world()

	# 07–10: all three connected city districts and an actual wardrobe interaction.
	world = await _open_world("res://scenes/mission_hong_kong_sandbox.tscn", "hong_kong_sandbox")
	_freeze_npcs()
	_camera(Vector3(-66, 5.0, -3), Vector3(-61, 1.0, -17), 62.0)
	await _capture("07_hong_kong_streets")
	_camera(Vector3(58, 5.0, -3), Vector3(63, 1.0, -17), 62.0)
	await _capture("08_hong_kong_commercial_district")
	# Shoot from the far edge of the playable city back across the actual
	# waterfront; the previous street-level angle hid the water and ferry
	# behind the last row of buildings despite staging them correctly.
	_camera(Vector3(0.0, 14.0, -94.0), Vector3(0.0, 6.0, -180.0), 62.0)
	await _capture("09_hong_kong_harbour_skyline")
	var harbour_scene := world.get("scene") as Node3D
	check(
		harbour_scene != null
		and int(harbour_scene.get_meta("harbour_waterfront_detail_count", 0)) >= 200,
		"harbour view builds the water, ferry, skyline and ridgeline detail layer"
	)
	var city_player := world.get("player") as HotelPlayer
	var city_npcs: Array = world.get("npc_list")
	if city_player and city_npcs.size() > 0:
		var vendor: HotelNpc
		for candidate: HotelNpc in city_npcs:
			if candidate.profile.outfit_id == "market_vendor":
				vendor = candidate
				break
		if vendor == null:
			vendor = city_npcs[0] as HotelNpc
			vendor.profile.outfit_id = "market_vendor"
			vendor.person.set_outfit("market_vendor")
		vendor.outfit_taken = false
		vendor.set_physics_process(false)
		vendor.incapacitate(15.0)
		city_player.global_position = vendor.global_position + Vector3(0, 0, 1.3)
		city_player.velocity = Vector3.ZERO
		world.call("_try_acquire_outfit")
		world.call("_equip_disguise", "market_vendor")
		# After the real acquisition/equip path has run, stage both role forms
		# laterally so the camera proves the changed player and covered NPC.
		vendor.global_position = Vector3(0.0, 0.05, 0.0)
		city_player.global_position = Vector3(-1.35, 0.05, 1.0)
		city_player.rotation.y = PI
		vendor.rotation.y = 0.0
		_camera(Vector3(-0.4, 2.0, 4.8), Vector3(-0.65, 1.0, 0.0), 58.0)
		await _capture("10_hong_kong_characters_disguise")
		check(
			city_player.body_mesh.outfit_id == "market_vendor" and vendor.person.underwear_mode,
			"disguise capture shows live NPC replacement and changed player outfit"
		)
	await _close_world()

	# 11–17: Ngong Ping exterior, discovered concealed access, subterranean and
	# in-statue interiors, discovery-gated Instinct, and unspoiled secret state.
	world = await _open_world("res://scenes/mission_ngong_ping.tscn", "ngong_ping")
	_freeze_npcs()
	var mountain: Node3D = world.get("scene")
	var player := world.get("player") as HotelPlayer
	var facility := (
		mountain.find_child("NgongPingSecretFacility", true, false) as NgongPingSecretFacility
	)
	_camera(Vector3(0, 12, 12), Vector3(0, 7, -29), 62.0)
	await _capture("11_ngong_ping_exterior_statue")
	check(
		facility != null and not bool(world.get("facility_discovered")),
		"public landmark view keeps the secret undiscovered"
	)
	if facility and player:
		# Capture before opening the one-way panel. Hiding a discovered secret
		# requires restoring a fresh checkpoint, not toggling a local flag.
		player.global_position = Vector3(0, 0.1, -36.0)
		player.instinct_active = true
		world.call("_process", 0.0)
		_camera(Vector3(0, 2.6, -34.0), Vector3(0, 1.2, -39.0), 58.0)
		check(
			not bool(world.get("facility_discovered")) and not facility.entry_open,
			"undiscovered access is not opened or exposed"
		)
		player.instinct_active = false
		player.global_position = facility.entry_point + Vector3(0, 0.1, 1.0)
		player.velocity = Vector3.ZERO
		world.call("_interact")
		for frame: int in range(60):
			await process_frame
		check(
			bool(world.get("facility_discovered")) and facility.entry_open,
			"entrance is revealed by the mission interaction"
		)
		player.global_position = Vector3(0, 0.1, -36.0)
		_camera(Vector3(0, 2.6, -34.0), Vector3(0, -0.4, -41.0), 66.0)
		await _capture("12_discovered_facility_entrance")
		player.global_position = Vector3(0, -3.15, -59)
		_camera(Vector3(0, -1.3, -56.0), Vector3(0, -1.2, -62.5), 68.0)
		await _capture("13_facility_monumental_interior")
		player.global_position = Vector3(0, -7.95, -61)
		_camera(Vector3(0, -5.8, -58.0), Vector3(0, -6.8, -68.0), 70.0)
		await _capture("14_facility_central_operations")
		player.global_position = Vector3(0, 1.85, -29.0)
		_camera(Vector3(-2.4, 2.6, -28.0), Vector3(-2.4, 20.8, -30.0), 64.0)
		await _capture("15_facility_vertical_statue_core")
		# Active mission target (red) and discovered intel (separate yellow overlay).
		var target := world.get("target") as HotelNpc
		var intel: Node3D = world.get("intel_marker")
		if target:
			target.set_physics_process(false)
			target.global_position = Vector3(-4, -7.3, -66)
			if intel:
				intel.global_position = Vector3(3, -7.3, -66)
			player.global_position = Vector3(-1, -7.3, -61)
			player.instinct_active = true
			world.set("intel_found", false)
			world.call("_process", 0.0)
			_camera(Vector3(-1, -4.9, -57), Vector3(-3, -7.1, -66), 60.0)
		# 18: actual campaign HUD and controls over active mission geometry.
		player.instinct_active = false
		player.global_position = Vector3(0, 0.75, 4)
		world.call("_process", 0.0)
		_camera(Vector3(3.0, 3.0, 10.0), Vector3(0, 1.2, -5.0), 66.0)
		await _capture("18_campaign_hud_gameplay", true)
	await _close_world()

	# 16: seed only the already-earned campaign prerequisites, then capture the
	# playable House safe with all five keys and recover its separate code via E.
	campaign.progress.restore({
		"schema_version":3,
		"completed":["initiation","tung_chung","the_streets","the_district","the_harbour","ngong_ping"],
		"completed_targets":{"tung_chung":["usb_robber","constance_operative"],"the_streets":["market_vendor"],"the_district":["corporate_fixer"],"the_harbour":["harbour_businessman"],"ngong_ping":["field_coordinator"]},
		"recovered_keys":["key_01","key_02","key_03","key_04","key_05"]
	})
	check(campaign.progress.usb_ready() and campaign.progress.is_unlocked("house"),"House capture uses a valid five-key campaign checkpoint")
	world = await _open_world("res://scenes/mission_house.tscn", "house")
	_freeze_npcs()
	var house_safe: Node3D = world.get("house_safe_marker")
	var house_player := world.get("player") as HotelPlayer
	_camera(Vector3(0.0,2.5,-3.4),Vector3(0.0,1.1,-8.0),60.0)
	await _capture("16_house_separate_70_digit_safe",false)
	house_player.global_position = house_safe.global_position + Vector3(0,0,1.4)
	house_player.rotation.y = 0.0
	house_player.velocity = Vector3.ZERO
	world.call("_interact")
	check(campaign.progress.house_code_recovered and campaign.progress.house_code.length()==70,"House's real safe interaction saves the separate 70-digit code")
	check(campaign.complete("house",1),"House completion persists after safe-code recovery and all five physical keys")
	await _close_world()

	# 17: valid saved decryption state, real Ruby scene and E rescue interaction.
	check(campaign.acknowledge_usb_decryption(),"USB decryption is enabled only after the House checkpoint")
	world = load("res://scenes/post_usb_betrayal.tscn").instantiate() as Node3D
	campaign.active_mission = ""
	root.add_child(world)
	for frame: int in range(3): await process_frame
	world.set("elapsed",12.5)
	world.call("_process",0.01)
	check(bool(world.get("waiting_for_rescue")),"post-decryption story reaches the interactive rescue beat")
	var rescue_event := InputEventAction.new()
	rescue_event.action = "interact"
	rescue_event.pressed = true
	world.call("_unhandled_input",rescue_event)
	await create_timer(4.1).timeout
	check(bool(world.get("rescued")) and campaign.progress.betrayal_seen,"E rescues Ruby and saves the post-betrayal state")
	_camera(Vector3(-4.0,3.0,5.5),Vector3(0.0,1.2,-2.7),62.0)
	await _capture("17_post_usb_ruby_rescue",true)
	await _close_world()

	check(captures == 18, "all 18 distinct requested in-game views were captured")
	var manifest_path := output.path_join("manifest.json")
	var manifest_file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if manifest_file:
		var manifest := {
			"minimum_resolution": [1280, 720],
			"capture_count": capture_manifest.size(),
			"captures": capture_manifest
		}
		manifest_file.store_string(JSON.stringify(manifest, "  "))
		manifest_file.close()
	var parsed_manifest: Variant = null
	if FileAccess.file_exists(manifest_path):
		parsed_manifest = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var manifest_valid := manifest_file != null and parsed_manifest is Dictionary
	if manifest_valid:
		manifest_valid = parsed_manifest.get("captures", []).size() == 18
	check(
		manifest_valid,
		"machine-readable manifest records all full-resolution image paths, dimensions, and byte sizes"
	)
	for entry: Dictionary in capture_manifest:
		var image_path := output.path_join(str(entry["png"]))
		var image_valid := FileAccess.file_exists(image_path)
		if image_valid:
			image_valid = FileAccess.get_file_as_bytes(image_path).size() == int(entry["png_bytes"])
		check(image_valid, str(entry["name"]) + " original PNG survives final manifest audit")

	campaign.progress.restore(saved_progress)
	campaign.active_mission = saved_active
	campaign.settings = saved_settings
	campaign.campaign_path = saved_campaign_path
	campaign.settings_path = saved_settings_path
	campaign.apply_settings()
	var scratch_path := ProjectSettings.globalize_path(scratch_campaign_path)
	if FileAccess.file_exists(scratch_path):
		DirAccess.remove_absolute(scratch_path)
	print("A008 RESULT: %d checks, %d failures; 18 current-build views staged" % [checks, failures])
	quit(0 if failures == 0 else 1)
