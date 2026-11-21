"""Team importer: python3 -m unittest discover -s tests -p 'test_*.py'

Checks tools/teams/import_teams.py: stadium-name cleanup (clean_stadium),
cut-short Team columns, the import report, and that the checked-in
data/teams/*.json matches what the importer makes from data/teams/source.
"""
import csv
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMPORT = os.path.join(ROOT, "tools", "teams", "import_teams.py")
_spec = importlib.util.spec_from_file_location("import_teams", IMPORT)
it = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(it)


class CleanStadiumTests(unittest.TestCase):
    def test_town_twice(self):
        self.assertEqual(it.clean_stadium("Burlington Burlington Timberhawks Field", "Burlington",
                                          "Burlington Timberhawks")[:2],
                         ("Burlington Timberhawks Field", "changed"))
        self.assertEqual(it.clean_stadium("Jacksonville Jacksonville Stadium", "Jacksonville", "")[:2],
                         ("Jacksonville Stadium", "changed"))

    def test_two_word_town_twice(self):
        self.assertEqual(it.clean_stadium("Fort Myers Fort Myers Aviators Field", "Fort Myers", "")[:2],
                         ("Fort Myers Aviators Field", "changed"))

    def test_town_and_cut_short_team(self):
        self.assertEqual(it.clean_stadium("New Bedford New Redtails Field", "New Bedford", "New Redtails")[:2],
                         ("New Bedford Redtails Field", "changed"))
        self.assertEqual(it.clean_stadium("St. Cloud St. Grizzlies Field", "St. Cloud", "St. Grizzlies")[:2],
                         ("St. Cloud Grizzlies Field", "changed"))

    def test_cut_short_needs_the_team_column(self):
        # Without a Team column that matches, the same shape is only a repeat.
        name, status, _ = it.clean_stadium("New Bedford New Redtails Field", "New Bedford", "")
        self.assertEqual((name, status), ("New Bedford New Redtails Field", "unsure"))

    def test_other_repeats_are_left_and_flagged(self):
        for stadium, city in (("Beaver Falls Beaver Stadium", "Beaver Falls"),
                              ("Prairie View Prairie Stadium", "Prairie View")):
            name, status, why = it.clean_stadium(stadium, city, "")
            self.assertEqual((name, status), (stadium, "unsure"), stadium)
            self.assertIn("repeats", why)

    def test_clean_names_untouched(self):
        for stadium, city, team in (("Waycross Foxes Field", "Waycross", "Foxes"),
                                    ("Rebel Field", "Hoboken", "Rebels"),
                                    ("Gainesville Marshals Stadium", "Gainesville", "Marshals"),
                                    ("", "Boise", ""), ("Boise Stadium", "", "")):
            self.assertEqual(it.clean_stadium(stadium, city, team), (stadium, "", ""), stadium)

    def test_cut_short_team(self):
        self.assertTrue(it.cut_short_team("New Redtails", "New Bedford"))
        self.assertTrue(it.cut_short_team("St. Grizzlies", "St. Cloud"))
        self.assertFalse(it.cut_short_team("Burlington Timberhawks", "Burlington"))
        self.assertFalse(it.cut_short_team("New Bedford Redtails", "New Bedford"))
        self.assertFalse(it.cut_short_team("Foxes", "Waycross"))
        self.assertEqual(it.nickname("New Redtails", "New Bedford"), "Redtails")
        self.assertEqual(it.nickname("St. Grizzlies", "St. Cloud"), "Grizzlies")


class ImportRunTests(unittest.TestCase):
    def run_import(self, rows, name="college_test.csv"):
        src = tempfile.mkdtemp()
        out = tempfile.mkdtemp()
        with open(os.path.join(src, name), "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
        p = subprocess.run([sys.executable, IMPORT, "--source", src, "--out", out],
                           capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
        teams = json.load(open(os.path.join(out, "college.json")))["teams"]
        report = open(os.path.join(out, "import_report.md"), encoding="utf-8").read()
        return {t["name"]: t for t in teams}, report

    def test_report_lists_every_change_and_doubt(self):
        row = {"Division": "D2", "Conference": "C", "City": "", "Team": "", "Stadium": ""}
        rows = [dict(row, School="Burlington Valley University", City="Burlington",
                     Team="Burlington Timberhawks", Stadium="Burlington Burlington Timberhawks Field"),
                dict(row, School="New Bedford Valley University", City="New Bedford",
                     Team="New Redtails", Stadium="New Bedford New Redtails Field"),
                dict(row, School="Geneva Valley University", City="Beaver Falls",
                     Team="Beaver Falls Forge", Stadium="Beaver Falls Beaver Stadium"),
                dict(row, School="Waycross College", City="Waycross", Team="Foxes", Stadium="Waycross Foxes Field")]
        teams, report = self.run_import(rows)
        self.assertEqual(teams["Burlington Valley University"]["stadium"]["name"], "Burlington Timberhawks Field")
        self.assertEqual(teams["New Bedford Valley University"]["stadium"]["name"], "New Bedford Redtails Field")
        self.assertEqual(teams["New Bedford Valley University"]["nickname"], "Redtails")
        self.assertEqual(teams["Geneva Valley University"]["stadium"]["name"], "Beaver Falls Beaver Stadium")
        self.assertEqual(teams["Waycross College"]["stadium"]["name"], "Waycross Foxes Field")
        self.assertIn("## Stadium names cleaned (2)", report)
        self.assertIn("| college_test.csv:2 | Burlington Valley University | Burlington Burlington Timberhawks Field "
                      "| Burlington Timberhawks Field |", report)
        self.assertIn("## Stadium names left as they were: please check (1)", report)
        self.assertIn("Beaver Falls Beaver Stadium", report)
        self.assertIn("## Team column cut short for multi-word towns (1)", report)
        self.assertIn("| New Redtails | Redtails |", report)
        self.assertNotIn("Waycross", report)


class CheckedInDataTests(unittest.TestCase):
    def test_data_matches_the_importer(self):
        out = tempfile.mkdtemp()
        p = subprocess.run([sys.executable, IMPORT, "--out", out], capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(p.returncode, 0, p.stdout)
        for name in ("high_school.json", "college.json", "pro.json", "import_report.md"):
            with open(os.path.join(out, name), encoding="utf-8") as a, \
                    open(os.path.join(ROOT, "data", "teams", name), encoding="utf-8") as b:
                self.assertEqual(a.read(), b.read(), name + " is stale: run tools/teams/import_teams.py")

    def test_d2_stadiums_are_town_nickname_field(self):
        teams = json.load(open(os.path.join(ROOT, "data", "teams", "college.json")))["teams"]
        d2 = [t for t in teams if t["division"] == "D2"]
        self.assertEqual(len(d2), 160)
        for t in d2:
            self.assertEqual(t["stadium"]["name"], "%s %s Field" % (t["city"], t["nickname"]), t["name"])


if __name__ == "__main__":
    unittest.main()
