"""Dependency-free checks for authored population data; not gameplay tests."""
import json
import re
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PopulationDataTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.people = json.loads((ROOT / "resources/hotel_population.json").read_text())

    def test_unique_named_identities(self):
        names = [person["identity"] for person in self.people]
        self.assertEqual(len(names), 3)
        self.assertEqual(len(names), len(set(names)))
        self.assertTrue(all(names))

    def test_schedules_have_valid_activities_and_durations(self):
        for person in self.people:
            self.assertIn(person["occupation"], {"civilian", "employee", "security", "manager", "special"})
            self.assertGreaterEqual(person["alertness"], 0)
            self.assertLessEqual(person["alertness"], 1)
            self.assertTrue(person["schedule"])
            for entry in person["schedule"]:
                self.assertIn(entry["activity"], {"working", "waiting", "conversing", "idle"})
                self.assertGreater(entry["duration"], 0)

    def test_destinations_fit_the_current_navmesh(self):
        for person in self.people:
            for position in [person["start"]] + [entry["destination"] for entry in person["schedule"]]:
                self.assertEqual(len(position), 3)
                self.assertLessEqual(abs(position[0]), 11.5)
                self.assertLessEqual(abs(position[2]), 7.5)

    def test_schedule_points_do_not_land_inside_partitions(self):
        for person in self.people:
            for position in [person["start"]] + [entry["destination"] for entry in person["schedule"]]:
                x, _, z = position
                for boundary in (2.0, 7.0):
                    if abs(x - boundary) < 0.5:
                        self.assertTrue(2.35 <= abs(z) <= 3.65)

    def test_record_configuration_is_consistent_and_accessible_by_layout(self):
        mission = json.loads((ROOT / "resources/meridian_mission.json").read_text())
        records = mission["records"]
        ids = [record["id"] for record in records]
        self.assertEqual(ids, ["ledger", "memo", "archive"])
        self.assertEqual(len(set(ids)), 3)
        self.assertEqual(mission["required_records"], 2)
        self.assertLessEqual(mission["required_records"], len(ids))
        for record in records:
            self.assertTrue(record["label"] and record["message"])
            x, y, z = record["position"]
            self.assertTrue(-11.0 < x < 11.0 and y == 0 and -7.0 < z < 7.0)
            for boundary in (2.0, 7.0):
                self.assertGreater(abs(x - boundary), 0.5)
            # Record markers must not be inside the visual counter/table footprints.
            for cx, cz, sx, sz in [(-5, -4.8, 4, 1), (-5, 3.5, 2.4, 1), (4.5, -5, 2.2, 1), (9.5, -5, 2.5, 1)]:
                self.assertFalse(abs(x - cx) < sx / 2 and abs(z - cz) < sz / 2)

    def test_primary_target_data_and_routes(self):
        meridian = json.loads((ROOT / "resources/meridian_mission.json").read_text())
        target = meridian["primary_target"]
        self.assertEqual(target["id"], "adrian_locke")
        self.assertNotIn(target["name"], [person["identity"] for person in self.people])
        self.assertTrue(target["description"] and target["schedule"])
        for x, y, z in [target["start"]] + [entry["destination"] for entry in target["schedule"]]:
            self.assertTrue(-41.0 < x < -34.5 and -13.5 < z < -6.0)
            self.assertGreaterEqual(y, 3.5)
        initiation = json.loads((ROOT / "resources/initiation_mission.json").read_text())
        self.assertEqual(initiation["primary_target"]["id"], "assessment_unit")
        self.assertEqual(initiation["required_action"], "disable_assessment_unit")

    def test_first_campaign_start_routes_through_bus_stop_and_agent_name(self):
        scene = ROOT / "scenes/bus_stop_opening.tscn"
        script = ROOT / "scripts/cinematics/bus_stop_opening.gd"
        campaign = (ROOT / "scripts/core/campaign_state.gd").read_text()
        progress = (ROOT / "scripts/core/campaign_progress.gd").read_text()
        self.assertTrue(scene.is_file())
        self.assertTrue(script.is_file())
        self.assertIn('id == "initiation" and not progress.bus_stop_seen', campaign)
        self.assertIn('var bus_stop_seen: bool = false', progress)
        self.assertIn('var agent_name: String = ""', progress)
        self.assertIn('"bus_stop_seen": bus_stop_seen', progress)
        self.assertIn('"agent_name": agent_name', progress)

    def test_hong_kong_campaign_has_distinct_ordered_city_operations(self):
        campaign = json.loads((ROOT / "resources/campaign.json").read_text())
        ops = json.loads((ROOT / "resources/hong_kong_operations.json").read_text())
        ids = [entry["id"] for entry in campaign["missions"]]
        self.assertEqual(ids[:6], ["initiation", "tung_chung", "the_streets", "the_district", "the_harbour", "ngong_ping"])
        self.assertEqual([campaign["missions"][i]["key_id"] for i in range(1, 6)], ["key_01", "key_02", "key_03", "key_04", "key_05"])
        self.assertEqual(campaign["missions"][6]["id"], "house")
        self.assertEqual(campaign["missions"][6]["target_ids"], [])
        self.assertTrue(campaign["missions"][-1].get("optional", False))
        self.assertEqual(campaign["missions"][-1]["id"], "meridian")
        self.assertTrue((ROOT / "scenes/mission_house.tscn").is_file())
        self.assertTrue((ROOT / "scenes/house_mission_map.tscn").is_file())
        house_script = (ROOT / "scripts/missions/hong_kong_operation.gd").read_text()
        code = re.search(r'const HOUSE_SAFE_CODE := "([0-9]+)"', house_script)
        self.assertIsNotNone(code)
        self.assertEqual(len(code.group(1)), 70)
        self.assertTrue((ROOT / "scenes/post_usb_betrayal.tscn").is_file())
        betrayal = (ROOT / "scripts/cinematics/post_usb_betrayal.gd").read_text()
        self.assertIn("PRESS E  /  PULL RUBY TO COVER", betrayal)
        self.assertIn("ten heads", betrayal.lower())
        self.assertNotIn("Rose", (ROOT / "HONG_KONG_MAP_PLAN.md").read_text())
        expected_targets = {
            "the_streets": "Market Vendor",
            "the_district": "Corporate Fixer",
            "the_harbour": "Wealthy Harbour Businessman",
        }
        for mission_id, target_name in expected_targets.items():
            entry = next(m for m in campaign["missions"] if m["id"] == mission_id)
            scene = ROOT / entry["scene"].removeprefix("res://")
            self.assertTrue(scene.is_file())
            self.assertIn(f'operation_id = "{mission_id}"', scene.read_text())
            self.assertEqual(ops[mission_id]["target"], target_name)
            self.assertEqual(ops[mission_id]["key_id"], entry["key_id"])
            self.assertEqual(ops[mission_id]["map"], "city")
        self.assertTrue((ROOT / "scripts/world/destructible_glass.gd").is_file())

    def test_city_operations_have_distinct_physical_key_locations(self):
        ops = json.loads((ROOT / "resources/hong_kong_operations.json").read_text())
        expected = {"the_streets": "key_02", "the_district": "key_03", "the_harbour": "key_04"}
        for mission_id, key_id in expected.items():
            self.assertEqual(ops[mission_id]["key_id"], key_id)
            self.assertIn(ops[mission_id]["placement"], {"guard", "safe", "target"})
            self.assertTrue(ops[mission_id]["clue"])

    def test_main_scene_and_script_exist(self):
        self.assertIn('run/main_scene="res://scenes/main_menu.tscn"', (ROOT / "project.godot").read_text())
        self.assertIn('res://scripts/world/hotel.gd', (ROOT / "scenes/hotel.tscn").read_text())
        self.assertTrue((ROOT / "scripts/world/hotel.gd").is_file())


if __name__ == "__main__":
    unittest.main()
