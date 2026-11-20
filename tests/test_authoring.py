"""Authoring tools: python3 -m unittest discover -s tests -p 'test_*.py'

Checks tools/import_scenarios.py on the finished examples (clean), on a
deliberately broken file (every error class reported, nothing written), and
that the templates match the live graph data.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMPORT = os.path.join(ROOT, "tools", "import_scenarios.py")


def run(*args):
    p = subprocess.run([sys.executable, IMPORT, *args], capture_output=True, text=True, cwd=ROOT)
    return p.returncode, p.stdout


class ImportTests(unittest.TestCase):
    def test_examples_are_clean(self):
        code, out = run(os.path.join(ROOT, "tools", "authoring", "examples.json"), "--dry-run")
        self.assertEqual(code, 0, out)
        self.assertIn("0 error(s), 0 warning(s)", out)

    def test_blank_template_is_skipped(self):
        code, out = run(os.path.join(ROOT, "tools", "authoring", "hs_template_all.json"), "--dry-run")
        self.assertEqual(code, 0, out)
        self.assertIn("0 written, 150 not written yet", out)

    def test_old_format_files_still_import(self):
        # Batch 1 was written from the template before leads_to became text lines.
        code, out = run(os.path.join(ROOT, "tools", "authoring", "work", "freshman_batch1.json"), "--dry-run")
        self.assertEqual(code, 0, out)
        self.assertIn("0 error(s), 0 warning(s)", out)

    def test_leads_to_says_unlocks_or_blocks(self):
        t = {e["id"]: e for e in json.load(open(os.path.join(ROOT, "tools", "authoring",
                                                             "hs_template_all.json")))["scenarios"]}
        leads = t["HS_003"]["_info"]["leads_to"]
        self.assertIn("unlocks HS_034 (The Friend Who Needs Help) when helped_freshman", leads)
        self.assertIn("blocks HS_034 (The Friend Who Needs Help) when bullied_freshman", leads)

    def test_bad_file_reports_every_problem(self):
        bad = {"scenarios": [
            {"id": "HS_014", "title": "x", "category": "weather", "text": "{coahc} brings beer.", "choices": [
                {"label": "A", "result": "a", "stats": {"life": {"energy": -30}, "football": {"speed": 2}},
                 "modifiers": [], "set_flags": {"helpd_freshman": True}, "rel": {"principal": 5, "coach": 40}},
                {"label": "", "result": "b", "stats": {}, "modifiers": ["sleepy"],
                 "requires": {"flags": ["befriended_tyler"]}}]},
            {"id": "HS_999", "title": "x", "category": "team", "text": "x", "choices": []}]}
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "bad.json")
            with open(path, "w") as f:
                json.dump(bad, f)
            data = os.path.join(d, "data")
            shutil.copytree(os.path.join(ROOT, "data", "career"), data)
            before = open(os.path.join(data, "scenarios_hs_graph.json")).read()
            code, out = run(path, "--data-dir", data)
            self.assertEqual(code, 1)
            for part in ["category 'weather'", "contains 'beer'", "unknown placeholder {coahc}",
                         "outside the life range", "'speed' is not a football stat", "needs a game-day modifier",
                         "unknown flag 'helpd_freshman'", "unknown person 'principal'", "rel coach 40",
                         "label is empty", "changes no stats", "unknown modifier 'sleepy'", "needs lock_text",
                         "unknown id"]:
                self.assertIn(part, out)
            self.assertIn("Nothing was written", out)
            self.assertEqual(open(os.path.join(data, "scenarios_hs_graph.json")).read(), before)

    def test_import_writes_and_keeps_graph_valid(self):
        with tempfile.TemporaryDirectory() as d:
            data = os.path.join(d, "data")
            shutil.copytree(os.path.join(ROOT, "data", "career"), data)
            code, out = run(os.path.join(ROOT, "tools", "authoring", "examples.json"), "--data-dir", data)
            self.assertEqual(code, 0, out)
            g = {s["id"]: s for s in json.load(open(os.path.join(data, "scenarios_hs_graph.json")))["scenarios"]}
            self.assertNotIn("draft", g["HS_005"])
            self.assertEqual(len(g["HS_005"]["choices"]), 3)
            self.assertTrue(g["HS_003F"]["follow_up_only"])
            self.assertEqual(g["HS_003"]["choices"][0]["follow_up"], {"id": "HS_003F", "weeks": 2})
            self.assertNotIn("rel", g["HS_014"]["choices"][0])  # empty slots dropped

    def test_templates_match_graph(self):
        graph = [s for s in json.load(open(os.path.join(ROOT, "data", "career", "scenarios_hs_graph.json")))
                 ["scenarios"] if not s.get("added_by_import")]
        tpl = json.load(open(os.path.join(ROOT, "tools", "authoring", "hs_template_all.json")))["scenarios"]
        self.assertEqual([t["id"] for t in tpl], [s["id"] for s in graph])
        fresh = json.load(open(os.path.join(ROOT, "tools", "authoring", "hs_template_freshman.json")))["scenarios"]
        self.assertEqual(len(fresh), 25)
        for t in tpl:
            must = t["_info"].get("must_set_flags", [])
            got = {f for c in t["choices"] for f in c.get("set_flags", {})}
            self.assertTrue(set(must) <= got, t["id"])


if __name__ == "__main__":
    unittest.main()


sys.path.insert(0, os.path.join(ROOT, "tools"))
import scenario_lint  # noqa: E402


class LintTests(unittest.TestCase):
    NAMES = scenario_lint.names_from_people(json.load(open(os.path.join(ROOT, "data", "career", "people.json"))))

    def codes(self, entry):
        return [c for c, _, _ in scenario_lint.lint_entry(entry, self.NAMES)]

    def choice(self, **kw):
        c = {"label": "Do it", "result": "Done.", "stats": {"life": {"energy": -2}}, "modifiers": ["focused"]}
        c.update(kw)
        return c

    def test_flags_each_problem(self):
        e = {"text": "{teacher} asks you to stay. She says you have potential.",
             "choices": [self.choice(result="You thank her. Dad nods. Late in a close game the kick is good."),
                         self.choice(label="It’s fine", result="Coach Rourke shrugs.")]}
        codes = self.codes(e)
        for c in ("pronoun", "hardcoded_name", "curly_quote", "game_kick"):
            self.assertIn(c, codes)
        self.assertEqual(codes.count("pronoun"), 2)  # "She" in the text, "her" in the result

    def test_male_cast_and_npcs_are_fine(self):
        e = {"text": "{tyler} misses three kicks in practice. He sits alone. A freshman says his gear is gone.",
             "choices": [self.choice(result="You help him reset; {holder} says they'll stay too."),
                         self.choice(stats={"life": {"energy": 2, "social": -3}}, result="The ball sails wide in practice.")]}
        self.assertEqual(self.codes(e), [])

    def test_dominance_counts_skill_points_and_rel(self):
        a = self.choice(stats={"life": {"energy": -2}}, skill_points=2)
        b = self.choice(stats={"life": {"energy": -2}}, rel={"coach": 3})
        self.assertEqual(self.codes({"text": "x", "choices": [a, b]}), [])
        c = self.choice(stats={"life": {"energy": -1, "social": 2}}, skill_points=2)
        self.assertIn("dominated", self.codes({"text": "x", "choices": [a, c]}))

    def test_pronoun_for_an_npc_is_not_flagged(self):
        e = {"text": "A trainer at the park says he coached college kickers. {coach} has never heard of him.",
             "choices": [self.choice(label="Ask {coach} about him", result="You ask, and he shrugs."),
                         self.choice(stats={"life": {"energy": 2, "social": -3}})]}
        self.assertNotIn("pronoun", self.codes(e))


# --- college tools -------------------------------------------------------------------------

COLLEGE_GEN = os.path.join(ROOT, "tools", "college_graph", "make_college_graph.py")


def _choice(**kw):
    c = {"label": "Do it", "result": "Done.", "stats": {"life": {"energy": -2}}, "modifiers": ["focused"]}
    c.update(kw)
    return c


class CollegeImportTests(unittest.TestCase):
    def test_tone_check_scenes_are_clean(self):
        code, out = run(os.path.join(ROOT, "tools", "authoring", "work", "col_tone_check.json"), "--dry-run")
        self.assertEqual(code, 0, out)
        self.assertIn("6 written", out)
        self.assertIn("0 error(s), 0 warning(s), 0 lint note(s)", out)

    def test_new_choice_fields_are_checked(self):
        bad = {"scenarios": [{"id": "COL_010", "title": "x", "category": "social", "text": "A party.", "draft": True,
                              "choices": [
            _choice(conduct="awful", followers=30, draft=-11),
            _choice(deal={"id": "d", "name": "D", "kind": "cash", "value": 1}, draft=True),
            _choice(set_flags={"missed_curfew": True}, requires={"followers_tier": "nobody"}, lock_text="x")]}]}
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "bad.json")
            with open(path, "w") as f:
                json.dump(bad, f)
            code, out = run(path, "--dry-run")
        self.assertEqual(code, 1, out)
        for msg in ["conduct 'awful'", "followers 30", "draft -11 is outside -10", "deal kind 'cash'",
                    "on a choice, \"draft\" is draft points", "\"draft\" at scenario level",
                    "followers_tier 'nobody'", "sets wrong-path strike 'missed_curfew'"]:
            self.assertIn(msg, out)

    def test_career_state_requirements_and_placeholders_accepted(self):
        ok = {"scenarios": [{"id": "COL_018", "title": "x", "category": "health", "text": "Back at {club} in {town}.",
                             "choices": [_choice(requires={"min": {"slump_now": 1, "clubs": 2}, "max": {"fg_streak": -3}},
                                                 lock_text="in a slump"), _choice(), _choice()]}]}
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "ok.json")
            with open(path, "w") as f:
                json.dump(ok, f)
            code, out = run(path, "--dry-run")
        self.assertNotIn("unknown requirement", out)
        self.assertNotIn("unknown placeholder", out)

    def test_suspend_weeks_is_checked(self):
        bad = {"scenarios": [{"id": "COL_010", "title": "x", "category": "team", "text": "A meeting.",
                              "choices": [_choice(suspend_weeks=5, conduct="bad", set_flags={"missed_curfew": True}),
                                          _choice(suspend_weeks=1)]}]}
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "bad.json")
            with open(path, "w") as f:
                json.dump(bad, f)
            code, out = run(path, "--dry-run")
        self.assertEqual(code, 1, out)
        self.assertIn("suspend_weeks 5 is over 3, which only a scene that plays only in the pros may use", out)
        self.assertIn("suspend_weeks without conduct bad or scandal", out)

    def test_wrong_path_step_must_clear_every_strike(self):
        bad = {"scenarios": [{"id": "COL_010", "title": "x", "category": "team", "text": "A meeting.",
                              "choices": [_choice(set_flags={"missed_curfew": False, "party_trouble": False}),
                                          _choice()]}]}
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "bad.json")
            with open(path, "w") as f:
                json.dump(bad, f)
            code, out = run(path, "--dry-run")
        self.assertEqual(code, 1, out)
        self.assertIn("must clear every strike flag; missing", out)

    def test_good_new_fields_pass(self):
        ok = {"scenarios": [{"id": "COL_018", "title": "x", "category": "health", "text": "Sessions are offered.",
                             "choices": [
            _choice(followers=3, conduct="good", set_flags={"saw_sports_psych": True}),
            _choice(stats={"life": {"energy": 2, "social": -2}}, deal={"id": "d", "name": "D", "kind": "sp",
                                                                     "value": 1, "seasons": 1},
                    set_flags={"brushed_off_psych": True})]}]}
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "ok.json")
            with open(path, "w") as f:
                json.dump(ok, f)
            code, out = run(path, "--dry-run")
        self.assertEqual(code, 0, out)


class CollegeGraphTests(unittest.TestCase):
    def test_generator_is_up_to_date(self):
        p = subprocess.run([sys.executable, COLLEGE_GEN, "--check"], capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(p.returncode, 0, p.stdout)

    def test_154_college_scenes_and_hand_written_kept(self):
        doc = json.load(open(os.path.join(ROOT, "data", "career", "scenarios_college.json")))
        col = [s for s in doc["scenarios"] if s["id"].startswith("COL_")]
        self.assertEqual(len(col), 154)
        self.assertTrue(any(s["id"] == "col_class_load" for s in doc["scenarios"]))
        self.assertTrue(all(s["stages"] == ["college"] for s in col))

    def test_regenerating_keeps_written_content(self):
        sys.path.insert(0, os.path.join(ROOT, "tools", "college_graph"))
        import make_college_graph as gen
        design = gen.load(gen.DESIGN)
        existing = {"scenarios": [{"id": "COL_001", "title": "old", "category": "family", "text": "Written.",
                                   "choices": [{"label": "a"}]}]}
        doc = gen.build(design, existing)
        s = next(x for x in doc["scenarios"] if x["id"] == "COL_001")
        self.assertEqual(s["text"], "Written.")
        self.assertNotIn("draft", s)
        self.assertEqual(s["title"], "Move-In Day")

    def test_wrong_path_steps_only_read_strikes_that_can_come_first(self):
        doc = json.load(open(os.path.join(ROOT, "data", "career", "scenarios_college.json")))
        office = next(s for s in doc["scenarios"] if s["id"] == "COL_036")
        self.assertIn("missed_curfew", office["requires"]["any_flags"])
        self.assertNotIn("senior_trip_trouble", office["requires"]["any_flags"])

    def test_no_offseason_scene_in_a_stage_last_season(self):
        sys.path.insert(0, os.path.join(ROOT, "tools"))
        import validate_scenario_graph as vsg
        last = vsg.stage_seasons()
        self.assertEqual(last["college"], 4)
        errs = []
        for f in os.listdir(os.path.join(ROOT, "data", "career")):
            if f.startswith("scenarios_") and f.endswith(".json"):
                for sc in json.load(open(os.path.join(ROOT, "data", "career", f)))["scenarios"]:
                    se = sc.get("seasons")
                    if sc.get("when") == ["offseason"] and se:
                        errs += [sc["id"] for st in sc.get("stages", []) if st in last and se[0] >= last[st]]
        self.assertEqual(errs, [])

    def test_wrong_path_steps_are_story_events_in_free_weeks(self):
        doc = json.load(open(os.path.join(ROOT, "data", "career", "scenarios_college.json")))
        s = {x["id"]: x for x in doc["scenarios"]}
        forced = {i: (s[i]["seasons"][1], s[i]["weeks"][1]) for i in ["COL_036", "COL_071", "COL_017", "COL_086", "COL_078"]}
        self.assertTrue(all(s[i].get("story") for i in forced))
        self.assertEqual(forced, {"COL_036": (3, 11), "COL_071": (4, 6), "COL_017": (4, 6), "COL_086": (4, 7),
                                  "COL_078": (4, 8)})
        p = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "validate_scenario_graph.py")],
                           capture_output=True, text=True, cwd=ROOT)
        self.assertNotIn("forced week", p.stdout)

    def test_college_template_shapes(self):
        t = json.load(open(os.path.join(ROOT, "tools", "authoring", "college_template_all.json")))["scenarios"]
        self.assertEqual(len(t), 154)
        for s in t:
            self.assertLessEqual(len(s["choices"]), 4, s["id"])
            if s["id"] != "COL_150":
                self.assertGreaterEqual(sum(1 for c in s["choices"] if not c.get("requires")), 2, s["id"])
        office = next(s for s in t if s["id"] == "COL_036")
        self.assertFalse(office["choices"][0]["set_flags"]["missed_curfew"])  # clears strikes

    def test_graph_check_prints_college_table(self):
        p = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "validate_scenario_graph.py")],
                           capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(p.returncode, 0, p.stdout)
        self.assertIn("## College scenarios available per season", p.stdout)


class CollegeLintTests(unittest.TestCase):
    NAMES = scenario_lint.names_from_people(json.load(open(os.path.join(ROOT, "data", "career", "people.json"))))

    def codes(self, entry):
        return [c for c, _, _ in scenario_lint.lint_entry(entry, self.NAMES)]

    def test_bad_conduct_needs_a_cost_and_cannot_win(self):
        e = {"text": "x", "choices": [_choice(stats={"life": {"fun": 5, "energy": -1}}, conduct="bad"),
                                      _choice(stats={"life": {"fun": 1, "energy": -2}})]}
        codes = self.codes(e)
        self.assertIn("conduct_cost", codes)
        self.assertIn("bad_choice_best", codes)
        e["choices"][0].update(draft=-2, rel={"coach": -4})
        e["choices"][0]["stats"]["life"]["energy"] = -6
        self.assertNotIn("conduct_cost", self.codes(e))

    def test_pressure_scene_needs_a_clean_no(self):
        e = {"text": "A party, and everybody does it.",
             "choices": [_choice(conduct="bad", draft=-1), _choice(stats={"life": {"fun": 2}}, conduct="bad", draft=-2)]}
        self.assertIn("pressure_no", self.codes(e))
        e["choices"][1].pop("conduct")
        self.assertNotIn("pressure_no", self.codes(e))

    def test_player_use_and_title_names(self):
        e = {"title": "Dad's Night", "text": "x",
             "choices": [_choice(result="You take one and feel nothing."), _choice(stats={"life": {"social": 2, "energy": -3}})]}
        codes = self.codes(e)
        self.assertIn("player_use", codes)
        self.assertIn("hardcoded_name", codes)
        e["title"] = "{parent}'s Night"
        self.assertNotIn("hardcoded_name", self.codes(e))

    def test_player_use_ignores_take_it_to(self):
        self.assertIsNone(scenario_lint.PLAYER_USE.search("You take it to the compliance office."))
        self.assertIsNotNone(scenario_lint.PLAYER_USE.search("You take it before warmups."))


class ProWritingStandardTests(unittest.TestCase):
    """The pro story writing floor and the repetition checks across the pro stage."""

    def _scene(self, sid, text, results, labels=None, rel=None):
        labels = labels or [f"Choice {i}" for i in range(len(results))]
        return {"id": sid, "stages": ["pro"], "text": text, "choices": [
            {"label": l, "result": r, "stats": {"life": {"energy": i - 1}}, "modifiers": ["focused"],
             **({"rel": rel} if rel else {})} for i, (l, r) in enumerate(zip(labels, results))]}

    def test_thin_premise_and_result_are_flagged_in_the_pros_only(self):
        e = self._scene("PRO_900", "Too short.", ["Done.", " ".join(["word"] * 25)])
        codes = [c for c, _, _ in scenario_lint.writing_findings(e)]
        self.assertEqual(codes, ["thin_text", "thin_result"])
        e["id"], e["stages"] = "HS_900", ["high_school"]
        self.assertEqual(scenario_lint.writing_findings(e), [])

    def test_repeated_labels_openings_and_stat_patterns(self):
        long = " ".join(["word"] * 25)
        scenes = [self._scene(f"PRO_9{i:02d}", long, ["You ask the coach " + long, "Fine " + long],
                              labels=["Pass", f"Other {i}"]) for i in range(5)]
        found = scenario_lint.corpus_findings(scenes)
        codes = {c for f in found.values() for c, _, _ in f}
        self.assertEqual(codes, {"label_repeat", "opening_repeat", "stat_pattern"})
        self.assertEqual(scenario_lint.corpus_findings(scenes[:3]), {})

    def test_one_relationship_target_taking_most_changes_is_flagged(self):
        long = " ".join(["word"] * 25)
        scenes = [self._scene(f"PRO_9{i:02d}", long, [long, long], rel={"coach": 1}) for i in range(6)]
        self.assertEqual([c for c, _, _ in scenario_lint.rel_balance_findings(scenes, 0.25)], ["rel_balance"])
        scenes[0]["choices"][0]["rel"] = {"parent": 1}
        for s, who in zip(scenes[1:], ["sibling", "holder", "backup", "best_friend", "rival"]):
            s["choices"][1]["rel"] = {who: 1}
        self.assertNotIn("coach", " ".join(m for _, _, m in scenario_lint.rel_balance_findings(scenes, 0.5)))


class RecastAndProSuspensionTests(unittest.TestCase):
    """Gameplay requests R8 (recast a cast member) and R9 (pro suspensions up to a season)."""

    def _run(self, doc):
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "x.json")
            with open(path, "w") as f:
                json.dump(doc, f)
            return run(path, "--dry-run")

    # Fixture: an unwritten era-6 draft (written last); repoint it if that changes.
    def test_pro_scene_may_suspend_a_season_and_recast(self):
        ok = {"scenarios": [{"id": "PRO_144", "title": "x", "category": "family", "text": "A dinner party.",
                             "choices": [_choice(recast=["love_interest"]),
                                         _choice(suspend_weeks=11, conduct="scandal"),
                                         _choice(suspend_weeks=6, conduct="bad")]}]}
        code, out = self._run(ok)
        self.assertEqual(code, 0, out)
        self.assertIn("0 error(s)", out)
        self.assertIn("a suspension over 3 weeks is for a serious step", out)  # bad conduct, no flag

    def test_bad_recast_and_suspension_values_are_errors(self):
        bad = {"scenarios": [{"id": "PRO_144", "title": "x", "category": "family", "text": "A dinner party.",
                              "choices": [_choice(recast=["team"]), _choice(recast=["nobody"]),
                                          _choice(recast="love_interest"), _choice(recast=["parent", "parent"]),
                                          _choice(suspend_weeks=12, conduct="scandal")]}]}
        code, out = self._run(bad)
        self.assertEqual(code, 1, out)
        for msg in ["can't replace 'team'", "recast 'nobody' is not a cast id", "recast must be a list",
                    "recast lists the same person twice", "suspend_weeks 12 must be a whole number 1-11"]:
            self.assertIn(msg, out)

    def test_recast_outside_the_pros_warns_and_rel_on_the_recast_person_warns(self):
        doc = {"scenarios": [{"id": "COL_010", "title": "x", "category": "social", "text": "A dinner.",
                              "choices": [_choice(recast=["love_interest"], rel={"love_interest": 3}), _choice()]}]}
        code, out = self._run(doc)
        self.assertIn("recast is meant for the pros", out)
        self.assertIn("the rel change goes to the person being replaced", out)
