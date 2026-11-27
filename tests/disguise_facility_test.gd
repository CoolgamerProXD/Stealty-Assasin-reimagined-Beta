extends SceneTree
## Godot 4.4.1 automated role, clothing, persistence, and final-operation checks.
## This validates runtime systems; it is not a human playthrough.
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition: print("DISGUISE PASS: ",label)
	else:
		failures += 1
		printerr("DISGUISE FAIL: ",label)

func any_visible(meshes: Array[MeshInstance3D]) -> bool:
	for mesh: MeshInstance3D in meshes:
		if is_instance_valid(mesh) and mesh.visible: return true
	return false

func run() -> void:
	var campaign := root.get_node("Campaign")
	var old_path: String = campaign.campaign_path
	var old_active: String = campaign.active_mission
	var old_progress: Dictionary = campaign.progress.snapshot()
	var temporary_campaign_path := "user://disguise_facility_test_%d.json" % Time.get_ticks_usec()
	campaign.campaign_path = temporary_campaign_path
	campaign.progress.restore({})
	var ids := DisguiseSystem.all_ids()
	check(ids.size() >= 12,"catalog provides distinct role-based outfits")
	check(DisguiseSystem.can_access("civilian","public") and not DisguiseSystem.can_access("civilian","office_staff"),"civilian permissions stay public")
	check(DisguiseSystem.can_access("market_vendor","market_staff") and not DisguiseSystem.can_access("market_vendor","executive_suite"),"market role is local, not universal")
	check(DisguiseSystem.can_access("office_employee","office_staff") and not DisguiseSystem.can_access("office_employee","market_staff"),"office clothing has commercial access only")
	check(DisguiseSystem.can_access("corporate_security","corporate_staff") and not DisguiseSystem.can_access("corporate_security","executive_suite"),"corporate security cannot enter the executive suite")
	check(DisguiseSystem.can_access("executive","executive_suite") and not DisguiseSystem.can_access("executive","facility_ops"),"executive clothes do not grant secret-facility access")
	check(DisguiseSystem.can_access("facility_technician","facility_maintenance") and not DisguiseSystem.can_access("facility_technician","facility_checkpoint"),"facility technician access is limited")
	check(DisguiseSystem.can_access("facility_security","facility_checkpoint") and not DisguiseSystem.can_access("facility_security","facility_ops"),"facility security access is checkpoint-scoped")
	check(DisguiseSystem.can_access("facility_research","facility_research") and DisguiseSystem.can_access("facility_research","buddha_interior") and not DisguiseSystem.can_access("facility_research","facility_ops"),"research attire grants only appropriate internal access")
	check(DisguiseSystem.can_access("facility_director","facility_ops") and DisguiseSystem.can_access("facility_director","buddha_interior"),"director attire reaches command and concealed statue spaces")

	var player := HotelPlayer.new()
	root.add_child(player)
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	await process_frame
	check(player.outfit_id == "civilian" and player.outfit_inventory == ["civilian"],"new player starts with only civilian clothing")
	check(player.body_mesh.cc0_model != null and player.body_mesh.cc0_skeleton != null and player.body_mesh.cc0_model_name in ["brad","dale","ellie","gary","hollis","pickles","rosa","vance"] and player.body_mesh.cc0_clothes.size() > 0,"player renders a textured, skinned CC0 character scene")
	check(not player.acquire_outfit("not_an_outfit") and not player.equip_outfit("market_vendor"),"invalid or unowned outfits cannot be added or equipped")
	check(player.acquire_outfit("market_vendor") and not player.acquire_outfit("market_vendor"),"acquisition succeeds once and prevents duplicates")
	check(player.equip_outfit("market_vendor") and player.role == "vendor" and player.body_mesh.outfit_id == "market_vendor","equipping changes gameplay role and visible character outfit")
	await process_frame
	check(player.body_mesh.cc0_model_name == "dale" and player.body_mesh.cc0_model != null and any_visible(player.body_mesh.cc0_clothes),"vendor outfit switches to an imported workwear body and visible garment mesh")
	check(player.body_mesh.vendor_apron.visible and not player.body_mesh.underwear_mode,"vendor outfit has its distinct procedural apron")
	check(player.acquire_outfit("facility_security") and player.equip_outfit("facility_security"),"special facility uniform can be acquired and switched to")
	await process_frame
	check(player.body_mesh.cc0_model_name == "gary" and player.body_mesh.cc0_model != null and player.body_mesh.weapon.get_parent() == player.body_mesh.right_hand_attachment,"switching outfits reloads the matching skinned model without losing hand equipment")
	var wardrobe := player.outfit_snapshot()
	player.equip_outfit("civilian")
	player.restore_outfits(wardrobe)
	await process_frame
	check(player.outfit_id == "facility_security" and player.outfit_inventory.has("market_vendor"),"checkpoint wardrobe restores owned and currently equipped outfits")
	campaign.progress.restore({})
	check(campaign.progress.acquire_outfit("market_vendor") and campaign.progress.equip_outfit("market_vendor"),"campaign progression stores recovered and equipped outfit IDs")
	var progress_copy := CampaignProgress.new()
	progress_copy.configure(JSON.parse_string(FileAccess.get_file_as_string("res://resources/campaign.json")))
	progress_copy.restore(campaign.progress.snapshot())
	check(progress_copy.acquired_outfits.has("market_vendor") and progress_copy.equipped_outfit == "market_vendor","campaign save migration retains only explicit outfit records")

	var subdued := HotelNpc.new()
	subdued.profile = NpcProfile.new()
	subdued.profile.identity = "Uniformed officer"
	subdued.profile.occupation = "security"
	subdued.profile.outfit_id = "facility_security"
	root.add_child(subdued)
	subdued.set_physics_process(false)
	await process_frame
	check(subdued.person.outfit_id == "facility_security" and subdued.person.role_hat.visible,"NPC role appearance is unique and uses its assigned uniform")
	check(subdued.incapacitate(12.0),"ordinary NPC can be temporarily subdued without objective completion")
	subdued.person.set_outfit("underwear")
	subdued.outfit_taken = true
	check(subdued.is_inside_tree() and subdued.person.underwear_mode and subdued.person.underwear_top.visible and subdued.person.boxer_shorts.visible,"clothing recovery leaves the NPC present and fully covered")
	check(subdued.person.cc0_model_name == "gary" and not any_visible(subdued.person.cc0_clothes) and not any_visible(subdued.person.cc0_shoes),"acquired clothing is removed from the NPC while the skinned model remains covered in underwear")
	check(not subdued.objective_completed and subdued.stunned_time > 0.0,"taking clothing does not convert incapacitation into target completion")

	# Exercise the real mission interaction, not just the appearance helper.
	campaign.progress.restore({"completed":["initiation","tung_chung"],"recovered_keys":["key_01"]})
	campaign.active_mission = "hong_kong_sandbox"
	var sandbox := load("res://scenes/mission_hong_kong_sandbox.tscn").instantiate() as Node3D
	root.add_child(sandbox)
	await process_frame
	await process_frame
	sandbox.call("_skip_cinematic")
	var targets: Array = sandbox.get("sandbox_targets")
	var loan_shark: HotelNpc = targets[0]
	loan_shark.set_physics_process(false)
	loan_shark.incapacitate(12.0)
	var player_in_sandbox: HotelPlayer = sandbox.get("player")
	player_in_sandbox.set_physics_process(false)
	player_in_sandbox.global_position = loan_shark.global_position + Vector3(0,0,1.2)
	check(sandbox.call("_try_acquire_outfit"),"mission interaction acquires clothing from a subdued real NPC")
	check(loan_shark.outfit_taken and loan_shark.person.underwear_mode and player_in_sandbox.outfit_inventory.has("market_vendor"),"live loot updates NPC appearance and player wardrobe together")
	sandbox.call("_equip_disguise","market_vendor")
	check(player_in_sandbox.outfit_id == "market_vendor" and AccessRules.can_enter(player_in_sandbox.role,"market_staff"),"field wardrobe selection changes role-based area access")
	var campaign_save: Dictionary = campaign.progress.snapshot()
	check(campaign_save["acquired_outfits"].has("market_vendor") and campaign_save["equipped_outfit"] == "market_vendor","wardrobe ownership and equip choice persist in campaign save data")
	sandbox.queue_free()
	await process_frame

	var house_map := load("res://scenes/house_mission_map.tscn").instantiate() as Node3D
	root.add_child(house_map)
	await process_frame
	var front_glazing := house_map.find_child("FrontWindowGlazing",true,false) as Node3D
	var glazing_material := front_glazing.get_child(0).get("material_override") as StandardMaterial3D if front_glazing else null
	check(glazing_material != null and glazing_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA and house_map.find_child("LivingRoomSofaPlacement",true,false) != null,"safehouse has framed glazed exterior openings and furnished living space")
	check(house_map.find_child("SafehousePlanningLaptopPlacement",true,false) != null and house_map.find_child("SafehousePaperworkPlacement",true,false) != null and house_map.find_child("KitchenPostPlacement",true,false) != null,"safehouse has a dedicated operational planning nook and distinct kitchen fitout")
	check(house_map.find_child("SafehousePrivateBedroomBedPlacement",true,false) != null and house_map.find_child("SafehousePrivateWingPortalHead",true,false) != null and house_map.find_child("WashroomShowerScreen",true,false) != null,"safehouse now has a partitioned sleeping wing, open cased entry, and glass-sided washroom")
	check(house_map.find_child("HouseholdPlumbingRiserPipe_0",true,false) != null and house_map.find_child("HouseholdWashroomPortalLeftReveal",true,false) != null and house_map.find_child("BedroomBedsideLamp",true,false) != null,"safehouse plumbing, washroom access, and bedside task light are built into the private wing")
	house_map.queue_free()
	await process_frame

	# Final-operation geometry and the concealed interior are checked in the
	# actual campaign scene. The entry is physically inside the rear Buddha base.
	campaign.progress.restore({"completed":["initiation","tung_chung","hong_kong_sandbox"],"recovered_keys":["key_01","key_02","key_03","key_04"]})
	campaign.active_mission = "ngong_ping"
	var final_world := load("res://scenes/mission_ngong_ping.tscn").instantiate() as Node3D
	root.add_child(final_world)
	await process_frame
	await process_frame
	final_world.call("_skip_cinematic")
	var mountain: Node3D = final_world.get("scene")
	var facility := mountain.find_child("NgongPingSecretFacility",true,false) as NgongPingSecretFacility
	var landmark := mountain.find_child("ScenicBuddhaLandmark",true,false) as Node3D
	check(facility != null and landmark != null and landmark.visible,"Ngong Ping contains the public Buddha landmark and attached hidden installation")
	var concealed_entry_guide: Node3D = mountain.find_child("EntryPortalGuide_Left",true,false) as Node3D
	var concealed_floor_guide: Node3D = mountain.find_child("EntryRampFloorGuide_Left",true,false) as Node3D
	check(concealed_entry_guide != null and not concealed_entry_guide.visible and concealed_floor_guide != null and not concealed_floor_guide.visible,"concealed portal and ramp-edge guidance stay hidden from the public approach")
	var hidden_chamber_floor := mountain.find_child("CrownOculusFloorSide",true,false) as Node3D
	check(hidden_chamber_floor != null and not hidden_chamber_floor.visible,"public exterior keeps world-space statue chambers out of the Buddha silhouette")
	check(mountain.find_child("FacilitySlab_Sublevel_1",true,false) != null and mountain.find_child("FacilitySlab_Sublevel_2",true,false) != null and mountain.find_child("FacilitySlab_Sublevel_3",true,false) != null and mountain.find_child("LOGISTICS_RECEIVING_&_CARGO_TRANSFER",true,false) != null and mountain.find_child("MEDICAL_RECOVERY_WARD",true,false) != null and mountain.find_child("UNDERGROUND_TRANSIT_SERVICE_DEPOT",true,false) != null,"expanded three-floor facility includes connected logistics, medical, and internal transit departments")
	check(mountain.find_child("BuddhaInteriorNavigation_1",true,false) != null and mountain.find_child("BuddhaInteriorNavigation_5",true,false) != null and mountain.find_child("CoreAtrium_2FloorSide",true,false) != null and mountain.find_child("CoreAtrium_3GuardRail",true,false) != null and mountain.find_child("CrownOculusFloorSide",true,false) != null and mountain.find_child("CrownOculusGuardRail",true,false) != null and mountain.find_child("CrownOculusRoofLight",true,false) != null and mountain.find_child("CrownOculusPractical",true,false) != null and mountain.find_child("StatueCoreConnectingRamp",true,false) != null,"five chamber floors connect through a protected, illuminated multi-storey core atrium to the buried installation")
	check(mountain.find_child("CentralOperationsFloor",true,false) != null and mountain.find_child("RESEARCH_LABORATORIES",true,false) != null and mountain.find_child("UNDERGROUND_TRANSIT_CONCOURSE",true,false) != null,"central operations, research, and transit spaces are present")
	check(mountain.find_child("PlayableServiceLiftCar",true,false) != null and mountain.find_child("ServiceLiftLandingSign_01",true,false) != null and mountain.find_child("LiftShaftGuideRail",true,false) != null,"a guarded, physically rideable lift connects the three underground floors through cut floor plates")
	check(mountain.find_child("AccessHallDirectoryTitle",true,false) != null and mountain.find_child("AccessHallDirectoryScreen",true,false) != null and mountain.find_child("AccessHallRouteMarker",true,false) != null,"monumental arrival hall has a framed route directory as its visible focal feature")
	check(mountain.find_child("FloorPanelJoint",true,false) != null and mountain.find_child("RecessedWallPanel",true,false) != null and mountain.find_child("RoomStructuralPilaster",true,false) != null and mountain.find_child("CeilingServiceSpine",true,false) != null,"PROMETHEUS rooms use panelized floor inlays, wall modules, structural piers and ceiling service spines")
	check(mountain.find_child("CeilingLightDiffuser",true,false) != null and mountain.find_child("DoorwayWayfindingStrip",true,false) != null,"facility interiors include practical ceiling fixtures and egress wayfinding")
	var entry_guide: OmniLight3D = mountain.find_child("HiddenAccessGuideLight",true,false) as OmniLight3D
	var entry_sconce: OmniLight3D = mountain.find_child("HiddenEntrySconce_Left",true,false) as OmniLight3D
	var hall_fill: OmniLight3D = mountain.find_child("AccessHallFocalLight",true,false) as OmniLight3D
	check(entry_guide != null and entry_guide.light_energy >= 7.99 and entry_sconce != null and entry_sconce.light_energy >= 4.49 and hall_fill != null and hall_fill.light_energy >= 4.49,"concealed entry and monumental access hall have dedicated shadowless readability fills")
	var ngong_environment: Environment = mountain.get_viewport().world_3d.environment
	check(ngong_environment != null and ngong_environment.ambient_light_energy >= 1.24,"Ngong Ping uses a warm ambient floor to preserve matte interior readability between practical lights")
	var level_practical_count := 0
	var level_practicals_are_lit := true
	var practical_sample := "none"
	for candidate: Node in facility.get_children():
		if candidate is OmniLight3D and candidate.name.begins_with("FacilityCeilingPractical_"):
			level_practical_count += 1
			var practical := candidate as OmniLight3D
			if level_practical_count == 1:
				practical_sample = "energy=%s range=%s shadows=%s" % [practical.light_energy,practical.omni_range,practical.shadow_enabled]
			level_practicals_are_lit = level_practicals_are_lit and practical.light_energy >= 3.19 and practical.omni_range >= 16.9 and not practical.shadow_enabled
	check(level_practical_count == 48 and level_practicals_are_lit,"three expanded sublevels use overlapping shadowless practical rows across the extended department footprint (count=%d, lit=%s, sample=%s)" % [level_practical_count,level_practicals_are_lit,practical_sample])
	check(mountain.find_child("DoorJamb",true,false) != null and mountain.find_child("SlidingDoorPocket",true,false) != null and mountain.find_child("ReturnAirGrilleSlat",true,false) != null and mountain.find_child("ConduitTrunk",true,false) != null,"facility room entrances, ventilation and electrical routes read as constructed systems")
	check(mountain.find_child("WalkThroughScannerUpright",true,false) != null and mountain.find_child("BunkFramePost",true,false) != null and mountain.find_child("FumeHoodBack",true,false) != null and mountain.find_child("CameraFeedLabelStrip",true,false) != null,"screening, staff quarters, research and surveillance each have purpose-built fitouts")
	check(mountain.find_child("AirHandlingUnit",true,false) != null and mountain.find_child("PlantPipeRiser",true,false) != null and mountain.find_child("ArchiveInventoryTable",true,false) != null and mountain.find_child("DirectorateBriefingDisplay",true,false) != null,"plant, archive and directorate spaces have distinct operating equipment")
	check(mountain.find_child("CargoOverheadHoistBeam",true,false) != null and mountain.find_child("CargoTransferCrate",true,false) != null and mountain.find_child("MedicalBedFrame",true,false) != null and mountain.find_child("MedicalPrivacyCurtain",true,false) != null and mountain.find_child("ClinicalWashBasin",true,false) != null and mountain.find_child("DepotGuideRail",true,false) != null and mountain.find_child("ServiceTrolleyDeck",true,false) != null,"new freight, recovery, and underground depot spaces have department-specific working fitouts")
	check(mountain.find_child("OperationsNorthWall",true,false) != null and mountain.find_child("OperationsPortalHeader",true,false) != null and mountain.find_child("OperationsWallPanelCap",true,false) != null,"Central Operations is enclosed by structural walls, a deliberate staff portal and articulated screen-wall bays")
	check(mountain.find_child("OperationsConsoleTopPanel",true,false) != null and mountain.find_child("OperationsKeyboard",true,false) != null and mountain.find_child("OperationsSecondaryDisplay",true,false) != null and mountain.find_child("OperationsPaperLog",true,false) != null and mountain.find_child("CommandMapGridLine",true,false) != null and mountain.find_child("OperationsTaskLight",true,false) != null,"command and operator desks now have mapped displays, work records and bounded practical task light")
	check(mountain.find_child("OperationsServiceRiserPipe_0",true,false) != null and mountain.find_child("OperationsPierBase",true,false) != null,"operations infrastructure resolves into load-bearing piers and maintainable service risers")
	var floor_inset := mountain.find_child("RoomFloorInset",true,false)
	var inset_mesh := floor_inset.get_child(0) as MeshInstance3D if floor_inset else null
	var floor_material := inset_mesh.material_override as StandardMaterial3D if inset_mesh else null
	check(floor_material != null and floor_material.albedo_texture != null and floor_material.roughness > 0.2,"PROMETHEUS concrete and terrazzo use authored surface finish maps")
	var statue_practicals := 0
	for candidate: Node in facility.get_children():
		if candidate is OmniLight3D and candidate.name.begins_with("BuddhaInteriorPractical_") and is_equal_approx((candidate as OmniLight3D).light_energy,0.78): statue_practicals += 1
	check(statue_practicals == 5,"each of the five occupied statue chambers has a distinct non-shadowing practical light")
	check(final_world.get("target").global_position.y < -7.0 and final_world.get("exit_marker").global_position.y < -7.0,"final coordinator and extraction occupy the hidden complex")
	var field_office := mountain.find_child("MountainFieldOffice",true,false)
	var key_marker: Node3D = final_world.get("key_marker")
	check(field_office != null and key_marker.global_position.y > 0.0 and key_marker.global_position.z > 0.0,"physical Key 05 remains in the separate accessible field archive")
	var operations_area := str(mountain.call("player_access_area",Vector3(0,-8.15,-66)))
	check(operations_area == "facility_ops" and not AccessRules.can_enter("executive",operations_area) and AccessRules.can_enter("facility_director",operations_area),"world geometry assigns Central Operations to a role-locked access zone")
	var facility_player: HotelPlayer = final_world.get("player")
	facility_player.set_physics_process(false)
	facility_player.global_position = facility.entry_point + Vector3(0,-0.45,1.2)
	final_world.call("_interact")
	check(bool(final_world.get("facility_discovered")) and facility.entry_open and concealed_entry_guide != null and concealed_entry_guide.visible and concealed_floor_guide.visible,"interacting with the real rear pedestal panel reveals the entrance and both portal and ramp-edge guide strips")
	var lift_player_start := Vector3(5.8,-3.04,-55.0)
	facility_player.global_position = lift_player_start
	facility_player.velocity = Vector3.ZERO
	facility_player.set_physics_process(false)
	facility_player.set_process_unhandled_input(false)
	final_world.set("intro_active",false)
	final_world.set("extraction_active",false)
	final_world.set("story_phase","")
	final_world.call("_interact")
	await create_timer(0.2).timeout
	check(facility.lift_busy,"E at the service lift landing starts the ride despite nearby staff interactions")
	await create_timer(2.6).timeout
	var lift_stop_two := facility_player.global_position.y
	final_world.call("_interact")
	await create_timer(2.8).timeout
	var lift_stop_three := facility_player.global_position.y
	final_world.call("_interact")
	await create_timer(2.8).timeout
	check(lift_stop_two < lift_player_start.y-4.0 and lift_stop_three < lift_stop_two-4.0 and absf(facility_player.global_position.y-lift_player_start.y) < 0.6,"E rides the collision-backed service car across all three connected sublevels and returns to the access hall")
	for npc: HotelNpc in final_world.get("npc_list"): npc.set_physics_process(false)
	facility_player.global_position = Vector3(0,0.75,-36.5)
	facility_player.rotation.y = 0.0
	facility_player.velocity = Vector3.ZERO
	facility_player.set_physics_process(true)
	facility_player.set_process_unhandled_input(true)
	for _frame: int in range(6): await physics_frame
	Input.action_press("move_forward")
	await create_timer(3.8).timeout
	Input.action_release("move_forward")
	print("DISGUISE ENTRY ROUTE: ",facility_player.global_position," velocity=",facility_player.velocity)
	check(facility_player.global_position.z < -44.0 and facility_player.global_position.y < -1.0,"player walks down the concealed ramp into Sublevel 01")
	check(ngong_environment != null and ngong_environment.ambient_light_energy >= 3.99,"facility locally lifts ambient exposure underground without over-brightening the public plaza")
	Input.action_press("move_back")
	await create_timer(7.8).timeout
	Input.action_release("move_back")
	print("DISGUISE CORE ROUTE: ",facility_player.global_position," velocity=",facility_player.velocity," inside=",facility.is_inside_statue(facility_player.global_position))
	check(facility.is_inside_statue(facility_player.global_position) and facility_player.global_position.y > 0.9 and not landmark.visible and hidden_chamber_floor.visible,"the continuous core ramp carries the player into a concealed chamber inside the landmark")
	check(final_world.find_child("DisguiseInventory",true,false) != null,"mission builds the playable disguise inventory UI")

	for node: Node in [final_world,subdued,player]:
		if is_instance_valid(node): node.queue_free()
	await process_frame
	campaign.campaign_path = old_path
	campaign.active_mission = old_active
	campaign.progress.restore(old_progress)
	for suffix: String in ["", ".bak", ".tmp"]:
		var file_path := temporary_campaign_path + suffix
		if FileAccess.file_exists(file_path): DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))
	if failures == 0: print("DISGUISE RESULT: %d checks, 0 failures" % checks)
	else: printerr("DISGUISE RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
