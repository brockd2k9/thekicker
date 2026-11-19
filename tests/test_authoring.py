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
